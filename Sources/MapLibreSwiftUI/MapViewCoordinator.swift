import Combine
import Foundation
import MapLibre
import MapLibreSwiftDSL

extension MLNCameraChangeReason: @retroactive CustomStringConvertible {
    private static let descriptions: [(Self, String)] = [
        (.programmatic, "programmatic"),
        (.resetNorth, "resetNorth"),
        (.gesturePan, "gesturePan"),
        (.gesturePinch, "gesturePinch"),
        (.gestureRotate, "gestureRotate"),
        (.gestureZoomIn, "gestureZoomIn"),
        (.gestureZoomOut, "gestureZoomOut"),
        (.gestureOneFingerZoom, "gestureOneFingerZoom"),
        (.gestureTilt, "gestureTilt"),
        (.transitionCancelled, "transitionCancelled"),
    ]

    public var description: String {
        var names = Self.descriptions.filter { contains($0.0) }.map(\.1)
        if names.isEmpty {
            names = ["none"]
        }
        return names.joined(separator: ",")
    }
}

@MainActor
public class MapViewCoordinator<T: MapViewHostViewController>: NSObject, @preconcurrency
MLNMapViewDelegate {
    // This must be weak, the UIViewRepresentable owns the MLNMapView.
    weak var mapView: MLNMapView?
    var parent: MapView<T>

    // Storage of variables as they were previously; these are snapshot
    // every update cycle so we can avoid unnecessary updates
    private var snapshotUserLayers: [StyleLayerDefinition] = []
    private var snapshotCamera: MapViewCamera?
    private var snapshotStyleSource: MapStyleSource?

    /// An asyncronous task that applies the camera update and awaits the map to reach idle state.
    var cameraUpdateTask: Task<Void, Never>?

    /// This continuation is closed with the MapView becomes idle at the end of a camera update.
    /// A canceled camera update (think a gesture midway through another camera update)
    /// should cancel and reset this.
    var cameraUpdateContinuation: CheckedContinuation<Void, Never>?

    var onStyleLoaded: ((MLNStyle) -> Void)?
    var onUserTrackingModeChange: ((MLNUserTrackingMode, Bool) -> Void)?
    var onMapIdle: ((MapViewProxy) -> Void)?
    var onMapDidFinishRendering: ((MapViewProxy, Bool) -> Void)?
    var onMapTileError: (() -> Void)?
    var onMapTileEvent: (@MainActor (MapTileEvent) -> Void)?
    var onGesture: (MLNMapView, UIGestureRecognizer) -> Void
    var onViewProxyChanged: (MapViewProxy) -> Void
    var proxyUpdateMode: ProxyUpdateMode
    var managedGestureRecognizers: [UIGestureRecognizer] = []
    var isUsingDefaultLocationManager = true

    /// Debounces rapid-fire tile error callbacks so the consumer receives one
    /// notification per burst rather than one per individual failing tile.
    private var tileErrorDebounceTask: Task<Void, Never>?

    init(
        parent: MapView<T>,
        onGesture: @escaping (MLNMapView, UIGestureRecognizer) -> Void,
        onViewProxyChanged: @escaping (MapViewProxy) -> Void,
        proxyUpdateMode: ProxyUpdateMode
    ) {
        self.parent = parent
        self.onGesture = onGesture
        self.onViewProxyChanged = onViewProxyChanged
        self.proxyUpdateMode = proxyUpdateMode
    }

    /// Seeds the snapshot with the style already applied during map view construction,
    /// so the first SwiftUI update does not redundantly reload the same style URL.
    func markStyleSourceApplied(_ source: MapStyleSource) {
        snapshotStyleSource = source
    }

    // MARK: Core UIView Functionality

    @objc func captureGesture(_ sender: UIGestureRecognizer) {
        guard let mapView else {
            return
        }

        onGesture(mapView, sender)
    }

    /// This function sets up a callback on the registered `MapViewGestureManager`.
    /// Each time the callback emits a modified list of gestures, they are synced to the map view.
    func registerGestureListener() {
        parent.gestureManager.onGestureChange = { [weak self] gestures in
            guard let self, let mapView else { return }
            syncGestures(on: mapView, gestures: gestures)
        }
    }

    // MARK: - Coordinator API - Styles + Layers

    @MainActor func updateStyleSource(_ source: MapStyleSource, mapView: MLNMapView) {
        switch (source, snapshotStyleSource) {
        case let (.url(newURL), .url(oldURL)):
            if newURL != oldURL {
                mapView.styleURL = newURL
            }
        case let (.url(newURL), .none):
            mapView.styleURL = newURL
        }

        snapshotStyleSource = source
    }

    @MainActor func updateLayers(mapView: MLNMapView) {
        // TODO: Figure out how to selectively update layers when only specific props changed. New function in addition to makeMLNStyleLayer?

        // TODO: Extract this out into a separate function or three...
        // Try to reuse DSL-defined sources if possible (they are the same type)!
        if let style = mapView.style {
            var sourcesToRemove = Set<String>()
            for layer in snapshotUserLayers {
                if let oldLayer = style.layer(withIdentifier: layer.identifier) {
                    style.removeLayer(oldLayer)
                }

                if let specWithSource = layer as? SourceBoundStyleLayerDefinition {
                    switch specWithSource.source {
                    case .mglSource:
                        // Do Nothing
                        // DISCUSS: The idea is to exclude "unmanaged" sources and only manage the ones specified via the DSL and attached to a layer.
                        // This is a really hackish design and I don't particularly like it.
                        continue
                    case .source:
                        // Mark sources for removal after all user layers have been removed.
                        // Sources specified in this way should be used by a layer already in the style.
                        sourcesToRemove.insert(specWithSource.source.identifier)
                    }
                }
            }

            // Remove sources that were added by layers specified in the DSL
            for sourceID in sourcesToRemove {
                if let source = style.source(withIdentifier: sourceID) {
                    style.removeSource(source)
                } else {
                    print("That's funny... couldn't find identifier \(sourceID)")
                }
            }
        }

        // Snapshot the new user-defined layers
        snapshotUserLayers = parent.userLayers

        // If the style is loaded, add the new layers to it.
        // Otherwise, this will get invoked automatically by the style didFinishLoading callback
        if let style = mapView.style {
            addLayers(to: style)
        }
    }

    func addLayers(to mglStyle: MLNStyle) {
        let firstSymbolLayer = mglStyle.layers.first { layer in
            layer is MLNSymbolStyleLayer
        }

        for layerSpec in parent.userLayers {
            // DISCUSS: What preventions should we try to put in place against the user accidentally adding the same layer twice?
            let newLayer = layerSpec.makeStyleLayer(style: mglStyle).makeMLNStyleLayer()

            // Unconditionally transfer the common properties
            newLayer.isVisible = layerSpec.isVisible

            if let minZoom = layerSpec.minimumZoomLevel {
                newLayer.minimumZoomLevel = minZoom
            }

            if let maxZoom = layerSpec.maximumZoomLevel {
                newLayer.maximumZoomLevel = maxZoom
            }

            switch layerSpec.insertionPosition {
            case let .above(.layer(layerId: id)):
                if let layer = mglStyle.layer(withIdentifier: id) {
                    mglStyle.insertLayer(newLayer, above: layer)
                } else {
                    NSLog("Failed to find layer with ID \(id). Adding layer on top.")
                    mglStyle.addLayer(newLayer)
                }
            case .above(.all):
                mglStyle.addLayer(newLayer)
            case let .below(.layer(layerId: id)):
                if let layer = mglStyle.layer(withIdentifier: id) {
                    mglStyle.insertLayer(newLayer, below: layer)
                } else {
                    NSLog("Failed to find layer with ID \(id). Adding layer on top.")
                    mglStyle.addLayer(newLayer)
                }
            case .below(.all):
                mglStyle.insertLayer(newLayer, at: 0)
            case .below(.symbols):
                if let firstSymbolLayer {
                    mglStyle.insertLayer(newLayer, below: firstSymbolLayer)
                } else {
                    mglStyle.addLayer(newLayer)
                }
            }
        }
    }

    // MARK: - Camera

    /// Apply a camera change based on the current @State of the camera.
    ///
    /// - Parameters:
    ///   - mapView: The MapView that the state is being updated for.
    ///   - camera: The new camera state
    ///   - animated: Whether the camera change should be animated. Defaults to `true`.
    @MainActor func applyCameraChangeFromStateUpdate(
        _ mapView: MLNMapViewRepresentable,
        camera: MapViewCamera,
        animated: Bool = true,
        reframing: Bool = false
    ) {
        // A content inset change interrupts any camera animation, so finish it within the new inset.
        // MapLibre reframes a camera that's already tracking.
        let isReframing = reframing
            && !(camera.state.isTrackingUserLocation && mapView.userTrackingMode != .none)
        guard camera != snapshotCamera || isReframing else {
            // No action - camera has not changed.
            return
        }

        snapshotCamera = camera

        // Cancel any existing camera update completion task.
        cameraUpdateTask?.cancel()

        cameraUpdateTask = Task { @MainActor in
            await withCheckedContinuation { continuation in
                guard !Task.isCancelled else {
                    continuation.resume()
                    return
                }

                // Clean up the continuation if it was already set.
                cameraUpdateContinuation?.resume()
                cameraUpdateContinuation = nil

                // Store the continuation to be resumed in mapViewDidBecomeIdle
                cameraUpdateContinuation = continuation

                mapView.apply(camera: camera, animated: animated)
            }
        }
    }

    /// Fits a bounding box or showcase camera to the map's new size.
    @MainActor func refitAfterResize() {
        guard !parent.cameraDisabled, let mapView, mapView.frame.size != .zero,
              let camera = snapshotCamera, camera == parent.camera
        else {
            return
        }
        switch camera.state {
        case .rect, .showcase:
            applyCameraChangeFromStateUpdate(mapView, camera: camera, animated: mapView.style != nil, reframing: true)
        case .centered, .trackingUserLocation, .trackingUserLocationWithHeading, .trackingUserLocationWithCourse:
            break
        }
    }

    /// Apply a gesture based camera change. This behavior will only be triggered on the first gesture and will
    /// only be completed when the mapView becomes idle.
    ///
    /// - Parameters:
    ///   - mapView: The MapView that is being manipulated by a gesture.
    ///   - reason: The reason for the camera change.
    @MainActor func applyCameraChangeFromGesture(_ mapView: MLNMapViewRepresentable, reason: CameraChangeReason) {
        guard cameraUpdateTask == nil else {
            // Gestures emit many updates, so we only want to launch the first one and rely on idle to close the event.
            return
        }

        cameraUpdateTask = Task { @MainActor in
            await withCheckedContinuation { continuation in
                guard !Task.isCancelled else {
                    continuation.resume()
                    return
                }

                // Store the continuation to be resumed in mapViewDidBecomeIdle
                cameraUpdateContinuation = continuation

                let pitchRange: CameraPitchRange = if mapView.minimumPitch == 0 && mapView.maximumPitch > 59.9 {
                    .free
                } else if mapView.minimumPitch == mapView.maximumPitch {
                    .fixed(mapView.minimumPitch)
                } else {
                    .freeWithinRange(minimum: mapView.minimumPitch, maximum: mapView.maximumPitch)
                }

                parent.camera = .center(
                    mapView.centerCoordinate,
                    zoom: mapView.zoomLevel,
                    pitch: mapView.camera.pitch,
                    pitchRange: pitchRange,
                    direction: mapView.direction,
                    reason: reason
                )
            }
        }
    }

    /// Cancels the pending camera update and resumes its continuation.
    ///
    /// Call this when SwiftUI removes the map view. Until the map becomes idle, the pending task holds
    /// the map view and the coordinator.
    @MainActor func cancelCameraUpdate() {
        cameraUpdateTask?.cancel()
        cameraUpdateTask = nil
        cameraUpdateContinuation?.resume()
        cameraUpdateContinuation = nil
    }

    // MARK: - MLNMapViewDelegate

    @MainActor
    public func mapView(_ mapView: MLNMapView, didFinishLoading mglStyle: MLNStyle) {
        addLayers(to: mglStyle)
        let viewProxy = MapViewProxy(
            mapView: mapView,
            lastReasonForChange: nil
        )
        onViewProxyChanged(viewProxy)
        onStyleLoaded?(mglStyle)
    }

    /// Called by MapLibre for every tile lifecycle event.
    ///
    /// Delivers every event on the main actor, then debounces error notifications to 300ms.
    ///
    /// MapLibre does not guarantee thread safety for this delegate callback.
    public nonisolated func mapView(
        _: MLNMapView,
        tileDidTriggerAction operation: MLNTileOperation,
        x _: Int,
        y _: Int,
        z _: Int,
        wrap _: Int,
        overscaledZ _: Int,
        sourceID: String
    ) {
        let event = MapTileEvent(operation: operation, sourceID: sourceID)
        Task { @MainActor in
            self.onMapTileEvent?(event)
            guard operation == .error else { return }
            self.debounceTileError()
        }
    }

    private func debounceTileError() {
        tileErrorDebounceTask?.cancel()
        tileErrorDebounceTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            onMapTileError?()
        }
    }

    /// The MapView's region has changed with a specific reason.
    @MainActor
    public func mapView(
        _ mapView: MLNMapView, regionDidChangeWith reason: MLNCameraChangeReason, animated _: Bool
    ) {
        // TODO: We could put this in regionIsChangingWith if we calculate significant change/debounce.
        // regionIsChangingWith is not called for the final update, so we need to call updateViewProxy
        // in both modes here.
        updateViewProxy(mapView: mapView, reason: reason)

        guard let changeReason = CameraChangeReason(reason) else {
            // Invalid state - we cannot process this camera change.
            return
        }

        switch changeReason {
        case .gesturePan, .gesturePinch, .gestureRotate,
             .gestureZoomIn, .gestureZoomOut, .gestureOneFingerZoom,
             .gestureTilt:
            applyCameraChangeFromGesture(mapView, reason: changeReason)
        default:
            break
        }
    }

    @MainActor
    public func mapViewDidBecomeIdle(_ mapView: MLNMapView) {
        cameraUpdateContinuation?.resume()
        cameraUpdateContinuation = nil
        cameraUpdateTask = nil

        let viewProxy = MapViewProxy(
            mapView: mapView,
            lastReasonForChange: nil
        )
        onMapIdle?(viewProxy)
    }

    @MainActor
    public func mapViewDidFinishRenderingMap(_ mapView: MLNMapView, fullyRendered: Bool) {
        let viewProxy = MapViewProxy(
            mapView: mapView,
            lastReasonForChange: nil
        )
        onMapDidFinishRendering?(viewProxy, fullyRendered)
    }

    @MainActor
    public func mapView(styleForDefaultUserLocationAnnotationView _: MLNMapView) -> MLNUserLocationAnnotationViewStyle {
        if let value = parent.annotationStyle?.value {
            value
        } else {
            MLNUserLocationAnnotationViewStyle()
        }
    }

    @MainActor
    public func mapView(_ mapView: MLNMapView, regionIsChangingWith reason: MLNCameraChangeReason) {
        if proxyUpdateMode == .realtime {
            updateViewProxy(mapView: mapView, reason: reason)
        }
    }

    @MainActor
    public func mapView(_: MLNMapView, didChange mode: MLNUserTrackingMode, animated: Bool) {
        onUserTrackingModeChange?(mode, animated)
    }

    // MARK: MapViewProxy

    @MainActor private func updateViewProxy(mapView: MLNMapView, reason: MLNCameraChangeReason) {
        // Calculate the Raw "ViewProxy"
        let calculatedViewProxy = MapViewProxy(
            mapView: mapView,
            lastReasonForChange: CameraChangeReason(reason)
        )

        onViewProxyChanged(calculatedViewProxy)
    }
}

public enum ProxyUpdateMode {
    /// Causes the `MapViewProxy`to be updated in realtime, including during map view scrolling and animations.
    /// This will cause multiple updates per seconds. Use only if you really need to run code in realtime while users
    /// are changing the shown region.
    case realtime
    /// Default. Causes `MapViewProxy` to be only be updated when a map view scroll or animation completes.
    case onFinish
}
