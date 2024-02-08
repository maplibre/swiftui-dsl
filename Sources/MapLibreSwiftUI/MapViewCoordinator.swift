import Foundation
import MapLibre
import MapLibreSwiftDSL

public class MapViewCoordinator: NSObject {
    
    // This must be weak, the UIViewRepresentable owns the MLNMapView.
    weak var mapView: MLNMapView?
    var parent:  MapView

    // Storage of variables as they were previously; these are snapshot
    // every update cycle so we can avoid unnecessary updates
    private var snapshotUserLayers: [StyleLayerDefinition] = []
    private var snapshotCamera: MapViewCamera?
    var onStyleLoaded: ((MLNStyle) -> Void)?
    var onGesture: (MLNMapView, UIGestureRecognizer) -> Void
    
    init(parent: MapView,
         onGesture: @escaping (MLNMapView, UIGestureRecognizer) -> Void) {
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

    func updateCamera(mapView: MLNMapViewCamera, camera: MapViewCamera, animated: Bool) {
        guard camera != snapshotCamera else {
            // No action - camera has not changed.
            return
        }
        
        switch camera.state {
        case .centered(let coordinate):
            mapView.userTrackingMode = .none
            mapView.setCenter(coordinate,
                              zoomLevel: camera.zoom,
                              direction: camera.direction,
                              animated: animated)
        case .trackingUserLocation:
            mapView.userTrackingMode = .follow
            mapView.setZoomLevel(camera.zoom, animated: false)
        case .trackingUserLocationWithHeading:
            mapView.userTrackingMode = .followWithHeading
            mapView.setZoomLevel(camera.zoom, animated: false)
        case .trackingUserLocationWithCourse:
            mapView.userTrackingMode = .followWithCourse
            mapView.setZoomLevel(camera.zoom, animated: false)
        case .rect, .showcase:
            // TODO: Need a method these/or to finalize a goal here.
            break
        }
        
        // Set the correct pitch range.
        mapView.minimumPitch = camera.pitch.rangeValue.lowerBound
        mapView.maximumPitch = camera.pitch.rangeValue.upperBound
        
        snapshotCamera = camera
    }
    
    // MARK: - Coordinator API - Styles + Layers
    
    func updateStyleSource(_ source: MapStyleSource, mapView: MLNMapView) {
        switch (source, parent.styleSource) {
        case (.url(let newURL), .url(let oldURL)):
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
                    case .mglSource(_):
                        // Do Nothing
                        // DISCUSS: The idea is to exclude "unmanaged" sources and only manage the ones specified via the DSL and attached to a layer.
                        // This is a really hackish design and I don't particularly like it.
                        continue
                    case .source(_):
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
            case .above(layerID: let id):
                if let layer = mglStyle.layer(withIdentifier: id) {
                    mglStyle.insertLayer(newLayer, above: layer)
                } else {
                    NSLog("Failed to find layer with ID \(id). Adding layer on top.")
                    mglStyle.addLayer(newLayer)
                }
            case .below(layerID: let id):
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
    
    public func mapView(_ mapView: MLNMapView, didFinishLoading mglStyle: MLNStyle) {
        onStyleLoaded?(mglStyle)
        addLayers(to: mglStyle)
    }

    /// The MapView's region has changed with a specific reason.
    public func mapView(_ mapView: MLNMapView, regionDidChangeWith reason: MLNCameraChangeReason, animated: Bool) {
        // Validate that the mapView.userTrackingMode still matches our desired camera state for each tracking type.
        let isFollowing = parent.camera.state == .trackingUserLocation && mapView.userTrackingMode == .follow
        let isFollowingHeading = parent.camera.state == .trackingUserLocationWithHeading && mapView.userTrackingMode == .followWithHeading
        let isFollowingCourse = parent.camera.state == .trackingUserLocationWithCourse && mapView.userTrackingMode == .followWithCourse
        
        // If any of these are a mismatch, we know the camera is no longer following a desired method, so we should detach and revert
        // to a .centered camera.
        if isFollowing || isFollowingHeading || isFollowingCourse {
            // User tracking, we can ignore camera updates until we unset this.
            return
        }
        
        // The user's desired camera is not a user tracking method, now we need to publish back the current mapView state to the camera binding.
        parent.camera = .center(mapView.centerCoordinate,
                                zoom: mapView.zoomLevel,
                                reason: CameraChangeReason(reason))
    }
}
