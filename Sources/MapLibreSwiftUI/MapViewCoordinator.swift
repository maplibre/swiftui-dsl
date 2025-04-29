import Foundation
import MapLibre
import MapLibreSwiftDSL

public class MapViewCoordinator<T: MapViewHostViewController>: NSObject, @preconcurrency
    MLNMapViewDelegate
{
    // This must be weak, the UIViewRepresentable owns the MLNMapView.
    weak var mapView: MLNMapView?
    var parent: MapView<T>

    // Storage of variables as they were previously; these are snapshot
    // every update cycle so we can avoid unnecessary updates
    private var snapshotUserLayers: [StyleLayerDefinition] = []
    var snapshotCamera: MapViewCamera?
    private var snapshotStyleSource: MapStyleSource?

    var cameraUpdateTask: Task<Void, Never>?
    var cameraUpdateContinuation: CheckedContinuation<Void, Never>?

    var onStyleLoaded: ((MLNStyle) -> Void)?
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

    public func mapViewDidBecomeIdle(_ mapView: MLNMapView) {
        cameraUpdateContinuation?.resume()
        cameraUpdateContinuation = nil
        cameraUpdateTask = nil
    }

    @MainActor
    public func mapView(_ mapView: MLNMapView, regionIsChangingWith reason: MLNCameraChangeReason) {
        if proxyUpdateMode == .realtime {
            updateViewProxy(mapView: mapView, reason: reason)
        }
    }

    // MARK: MapViewProxy

    @MainActor private func updateViewProxy(mapView: MLNMapView, reason: MLNCameraChangeReason) {
        // Calculate the Raw "ViewProxy"
        let calculatedViewProxy = MapViewProxy(
            mapView: mapView,
            lastReasonForChange: CameraChangeReason(reason))

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
