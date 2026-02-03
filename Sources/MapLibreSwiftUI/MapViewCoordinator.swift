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
        if names.isEmpty { names = ["none"] }
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
    var onGesture: (MLNMapView, UIGestureRecognizer) -> Void
    var onViewProxyChanged: (MapViewProxy) -> Void
    var proxyUpdateMode: ProxyUpdateMode

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
        animated: Bool = true
    ) {
        guard camera != snapshotCamera else {
            // No action - camera has not changed.
            return
        }

        snapshotCamera = camera

        // Cancel any existing camera update completion task.
        cameraUpdateTask?.cancel()

        cameraUpdateTask = Task { @MainActor in
            return await withCheckedContinuation { continuation in
                // Clean up the continuation if it was already set.
                cameraUpdateContinuation?.resume()
                cameraUpdateContinuation = nil

                // Store the continuation to be resumed in mapViewDidBecomeIdle
                cameraUpdateContinuation = continuation

                // Apply the camera settings based on camera.state
                switch camera.state {
                case let .centered(
                    onCoordinate: coordinate,
                    zoom: zoom,
                    pitch: pitch,
                    pitchRange: pitchRange,
                    direction: direction
                ):
                    mapView.userTrackingMode = .none

                    if mapView.frame.size == .zero {
                        // On init, the mapView's frame is not set up yet, so manipulation via camera is broken,
                        // so let's do something else instead.
                        mapView.setCenter(coordinate,
                                          zoomLevel: zoom,
                                          direction: direction,
                                          animated: animated)

                        // this is a workaround for no camera - minimum and maximum will be reset below, but this
                        // adjusts it.
                        mapView.minimumPitch = pitch
                        mapView.maximumPitch = pitch

                    } else {
                        let camera = mapView.camera
                        camera.centerCoordinate = coordinate
                        camera.heading = direction
                        camera.pitch = pitch

                        let altitude = MLNAltitudeForZoomLevel(zoom, pitch, coordinate.latitude, mapView.frame.size)
                        camera.altitude = altitude
                        mapView.setCamera(camera, animated: animated)
                    }

                    mapView.minimumPitch = pitchRange.rangeValue.lowerBound
                    mapView.maximumPitch = pitchRange.rangeValue.upperBound
                case let .trackingUserLocation(zoom: zoom, pitch: pitch, pitchRange: pitchRange, direction: direction):
                    if mapView.frame.size == .zero {
                        // On init, the mapView's frame is not set up yet, so manipulation via camera is broken,
                        // so let's do something else instead.
                        // Needs to be non-animated or else it messes up following

                        mapView.userTrackingMode = .follow

                        mapView.zoomLevel = zoom
                        mapView.direction = direction

                        mapView.minimumPitch = pitch
                        mapView.maximumPitch = pitch
                        mapView.minimumPitch = pitchRange.rangeValue.lowerBound
                        mapView.maximumPitch = pitchRange.rangeValue.upperBound
                    } else {
                        mapView.setUserTrackingMode(.follow, animated: animated) {
                            guard mapView.userTrackingMode == .follow else {
                                // Exit early if the user tracking mode is no longer set to follow
                                return
                            }

                            mapView.zoomLevel = zoom
                            mapView.direction = direction

                            mapView.minimumPitch = pitch
                            mapView.maximumPitch = pitch
                            mapView.minimumPitch = pitchRange.rangeValue.lowerBound
                            mapView.maximumPitch = pitchRange.rangeValue.upperBound
                        }
                    }
                case let .trackingUserLocationWithHeading(zoom: zoom, pitch: pitch, pitchRange: pitchRange):
                    if mapView.frame.size == .zero {
                        // On init, the mapView's frame is not set up yet, so manipulation via camera is broken,
                        // so let's do something else instead.
                        // Needs to be non-animated or else it messes up following

                        mapView.userTrackingMode = .followWithHeading

                        mapView.zoomLevel = zoom

                        mapView.minimumPitch = pitch
                        mapView.maximumPitch = pitch
                        mapView.minimumPitch = pitchRange.rangeValue.lowerBound
                        mapView.maximumPitch = pitchRange.rangeValue.upperBound
                    } else {
                        mapView.setUserTrackingMode(.followWithHeading, animated: animated) {
                            guard mapView.userTrackingMode == .followWithHeading else {
                                // Exit early if the user tracking mode is no longer set to followWithHeading
                                return
                            }

                            mapView.zoomLevel = zoom

                            mapView.minimumPitch = pitch
                            mapView.maximumPitch = pitch
                            mapView.minimumPitch = pitchRange.rangeValue.lowerBound
                            mapView.maximumPitch = pitchRange.rangeValue.upperBound
                        }
                    }
                case let .trackingUserLocationWithCourse(zoom: zoom, pitch: pitch, pitchRange: pitchRange):
                    if mapView.frame.size == .zero {
                        mapView.userTrackingMode = .followWithCourse
                        // On init, the mapView's frame is not set up yet, so manipulation via camera is broken,
                        // so let's do something else instead.
                        // Needs to be non-animated or else it messes up following

                        mapView.zoomLevel = zoom

                        mapView.minimumPitch = pitch
                        mapView.maximumPitch = pitch
                        mapView.minimumPitch = pitchRange.rangeValue.lowerBound
                        mapView.maximumPitch = pitchRange.rangeValue.upperBound
                    } else {
                        mapView.setUserTrackingMode(.followWithCourse, animated: animated) {
                            guard mapView.userTrackingMode == .followWithCourse else {
                                // Exit early if the user tracking mode is no longer set to followWithCourse
                                return
                            }

                            mapView.zoomLevel = zoom

                            mapView.minimumPitch = pitch
                            mapView.maximumPitch = pitch
                            mapView.minimumPitch = pitchRange.rangeValue.lowerBound
                            mapView.maximumPitch = pitchRange.rangeValue.upperBound
                        }
                    }
                case let .rect(boundingBox, padding):
                    mapView.minimumPitch = 0
                    mapView.maximumPitch = 0
                    mapView.direction = 0

                    mapView.setVisibleCoordinateBounds(boundingBox,
                                                       edgePadding: padding,
                                                       animated: animated,
                                                       completionHandler: nil)
                case .showcase:
                    // TODO: Need a method these/or to finalize a goal here.
                    break
                }
            }
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

    // MARK: - MLNMapViewDelegate

    public func mapView(_: MLNMapView, didFinishLoading mglStyle: MLNStyle) {
        addLayers(to: mglStyle)
        onStyleLoaded?(mglStyle)
    }

    /// The MapView's region has changed with a specific reason.
    public func mapView(
        _ mapView: MLNMapView, regionDidChangeWith reason: MLNCameraChangeReason, animated _: Bool
    ) {
        // TODO: We could put this in regionIsChangingWith if we calculate significant change/debounce.
        MainActor.assumeIsolated {
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
    }

    public func mapViewDidBecomeIdle(_: MLNMapView) {
        cameraUpdateContinuation?.resume()
        cameraUpdateContinuation = nil
        cameraUpdateTask = nil
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
