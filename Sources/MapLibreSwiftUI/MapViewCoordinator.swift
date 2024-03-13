import Foundation
import MapLibre
import MapLibreSwiftDSL

public class MapViewCoordinator: NSObject {
    // This must be weak, the UIViewRepresentable owns the MLNMapView.
    weak var mapView: MLNMapView?
    var parent: MapView

    // Storage of variables as they were previously; these are snapshot
    // every update cycle so we can avoid unnecessary updates
    private var snapshotUserLayers: [StyleLayerDefinition] = []
    private var snapshotCamera: MapViewCamera?
    var onStyleLoaded: ((MLNStyle) -> Void)?
    var onGesture: (MLNMapView, UIGestureRecognizer) -> Void

    init(parent: MapView,
         onGesture: @escaping (MLNMapView, UIGestureRecognizer) -> Void)
    {
        self.parent = parent
        self.onGesture = onGesture
    }

    // MARK: Core UIView Functionality

    @objc func captureGesture(_ sender: UIGestureRecognizer) {
        guard let mapView else {
            return
        }

        onGesture(mapView, sender)
    }

    // MARK: - Coordinator API - Camera + Manipulation

    /// Update the camera based on the MapViewCamera binding change.
    ///
    /// - Parameters:
    ///   - mapView: This is the camera updating protocol representation of the MLNMapView. This allows mockable testing
    /// for
    /// camera related MLNMapView functionality.
    ///   - camera: The new camera from the binding.
    ///   - animated: Whether to animate.
    func updateCamera(mapView: MLNMapViewCameraUpdating, camera: MapViewCamera, animated: Bool) {
        guard camera != snapshotCamera else {
            // No action - camera has not changed.
            return
        }

        switch camera.state {
        case let .centered(onCoordinate: coordinate, zoom: zoom, pitch: pitch, direction: direction):
            mapView.userTrackingMode = .none
            mapView.setCenter(coordinate,
                              zoomLevel: zoom,
                              direction: direction,
                              animated: animated)
            mapView.minimumPitch = pitch.rangeValue.lowerBound
            mapView.maximumPitch = pitch.rangeValue.upperBound
        case let .trackingUserLocation(zoom: zoom, pitch: pitch):
            mapView.userTrackingMode = .follow
            // Needs to be non-animated or else it messes up following
            mapView.setZoomLevel(zoom, animated: false)
            mapView.minimumPitch = pitch.rangeValue.lowerBound
            mapView.maximumPitch = pitch.rangeValue.upperBound
        case let .trackingUserLocationWithHeading(zoom: zoom, pitch: pitch):
            mapView.userTrackingMode = .followWithHeading
            // Needs to be non-animated or else it messes up following
            mapView.setZoomLevel(zoom, animated: false)
            mapView.minimumPitch = pitch.rangeValue.lowerBound
            mapView.maximumPitch = pitch.rangeValue.upperBound
        case let .trackingUserLocationWithCourse(zoom: zoom, pitch: pitch):
            mapView.userTrackingMode = .followWithCourse
            // Needs to be non-animated or else it messes up following
            mapView.setZoomLevel(zoom, animated: false)
            mapView.minimumPitch = pitch.rangeValue.lowerBound
            mapView.maximumPitch = pitch.rangeValue.upperBound
        case let .rect(boundingBox, padding):
            mapView.setVisibleCoordinateBounds(boundingBox,
                                               edgePadding: padding,
                                               animated: animated,
                                               completionHandler: nil)
        case .showcase:
            // TODO: Need a method these/or to finalize a goal here.
            break
        }

        snapshotCamera = camera
    }

    // MARK: - Coordinator API - Styles + Layers

    func updateStyleSource(_ source: MapStyleSource, mapView: MLNMapView) {
        switch (source, parent.styleSource) {
        case let (.url(newURL), .url(oldURL)):
            if newURL != oldURL {
                mapView.styleURL = newURL
            }
        }
    }

    func updateLayers(mapView: MLNMapView) {
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
            case let .above(layerID: id):
                if let layer = mglStyle.layer(withIdentifier: id) {
                    mglStyle.insertLayer(newLayer, above: layer)
                } else {
                    NSLog("Failed to find layer with ID \(id). Adding layer on top.")
                    mglStyle.addLayer(newLayer)
                }
            case let .below(layerID: id):
                if let layer = mglStyle.layer(withIdentifier: id) {
                    mglStyle.insertLayer(newLayer, below: layer)
                } else {
                    NSLog("Failed to find layer with ID \(id). Adding layer on top.")
                    mglStyle.addLayer(newLayer)
                }
            case .aboveOthers:
                mglStyle.addLayer(newLayer)
            case .belowOthers:
                mglStyle.insertLayer(newLayer, at: 0)
            }
        }
    }
}

// MARK: - MLNMapViewDelegate

extension MapViewCoordinator: MLNMapViewDelegate {
    public func mapView(_: MLNMapView, didFinishLoading mglStyle: MLNStyle) {
        addLayers(to: mglStyle)
        onStyleLoaded?(mglStyle)
    }

    /// The MapView's region has changed with a specific reason.
    public func mapView(_ mapView: MLNMapView, regionDidChangeWith reason: MLNCameraChangeReason, animated _: Bool) {
        // If any of these are a mismatch, we know the camera is no longer following a desired method, so we should
        // detach and revert to a .centered camera. If any one of these is true, the desired camera state still
        // matches the mapView's userTrackingMode
        let isProgrammaticallyTracking: Bool = switch parent.camera.state {
        case .centered(onCoordinate: _):
            false
        case .trackingUserLocation:
            mapView.userTrackingMode == .follow
        case .trackingUserLocationWithHeading:
            mapView.userTrackingMode == .followWithHeading
        case .trackingUserLocationWithCourse:
            mapView.userTrackingMode == .followWithCourse
        case .rect(boundingBox: _, edgePadding: _):
            false
        case .showcase(shapeCollection: _):
            false
        }

        if isProgrammaticallyTracking {
            // Programmatic tracking is still active, we can ignore camera updates until we unset/fail this boolean
            // check
            return
        }

        DispatchQueue.main.async {
            // Publish the MLNMapView's "raw" camera state to the MapView camera binding.
            self.parent.camera = .center(mapView.centerCoordinate,
                                         zoom: mapView.zoomLevel,
                                         reason: CameraChangeReason(reason))
        }
    }
}
