import SwiftUI
import InternalUtils
import MapLibre
import MapLibreSwiftDSL
import MapLibreSwiftUI

public struct MapView: UIViewRepresentable {
    
    public private(set) var camera: Binding<MapViewCamera>?

    public let styleSource: MapStyleSource
    public let userLayers: [StyleLayerDefinition]

    public init(
        styleURL: URL,
        camera: Binding<MapViewCamera>? = nil,
        @MapViewContentBuilder _ makeMapContent: () -> [StyleLayerDefinition] = { [] }
    ) {
        self.styleSource = .url(styleURL)
        self.camera = camera

        userLayers = makeMapContent()
    }

    public init(
        styleURL: URL,
        initialCamera: MapViewCamera,
        @MapViewContentBuilder _ makeMapContent: () -> [StyleLayerDefinition] = { [] }
    ) {
        self.init(styleURL: styleURL, camera: .constant(initialCamera), makeMapContent)
    }

    public class Coordinator: NSObject, MLNMapViewDelegate {
        var parent:  MapView

        // Storage of variables as they were previously; these are snapshot
        // every update cycle so we can avoid unnecessary updates
        private var snapshotUserLayers: [StyleLayerDefinition] = []
        var snapshotCamera: MapViewCamera?
        
        init(parent: MapView) {
            self.parent = parent
        }

        // MARK: - MLNMapViewDelegate

        public func mapView(_ mapView: MLNMapView, didFinishLoading mglStyle: MLNStyle) {
            addLayers(to: mglStyle)
        }

        func updateStyleSource(_ source: MapStyleSource, mapView: MLNMapView) {
            switch (source, parent.styleSource) {
            case (.url(let newURL), .url(let oldURL)):
                if newURL != oldURL {
                    mapView.styleURL = newURL
                }
            }
        }

        public func mapView(_ mapView: MLNMapView, regionDidChangeAnimated animated: Bool) {
            DispatchQueue.main.async {
                self.parent.camera?.wrappedValue = .center(mapView.centerCoordinate,
                                                           zoom:  mapView.zoomLevel)
            }
        }

        // MARK: - Coordinator API

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

    public func makeUIView(context: Context) -> MLNMapView {
        // Create the map view
        let mapView = MLNMapView(frame: .zero)
        mapView.delegate = context.coordinator

        switch styleSource {
        case .url(let styleURL):
            mapView.styleURL = styleURL
        }

        updateMapCamera(mapView, context: context, animated: false)

        // TODO: Make this settable via a modifier
        mapView.logoView.isHidden = true

        return mapView
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    public func updateUIView(_ mapView: MLNMapView, context: Context) {
        context.coordinator.parent = self
        // FIXME: This should be a more selective update
        context.coordinator.updateStyleSource(styleSource, mapView: mapView)
        context.coordinator.updateLayers(mapView: mapView)

        // FIXME: This isn't exactly telling us if the *map* is loaded, and the docs for setCenter say it needs t obe.
        let isStyleLoaded = mapView.style != nil

        updateMapCamera(mapView, context: context, animated: isStyleLoaded)
    }

    private func updateMapCamera(_ mapView: MLNMapView, context: Context, animated: Bool) {
        guard let newCamera = self.camera?.wrappedValue,
              context.coordinator.snapshotCamera != newCamera else {
            // Exit early - the camera has not changed.
            return
        }
        
        mapView.setCenter(newCamera.coordinate,
                          zoomLevel: newCamera.zoom,
                          direction: newCamera.course,
                          animated: animated)
        
        context.coordinator.snapshotCamera = newCamera
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        let demoTilesURL = URL(string: "https://demotiles.maplibre.org/style.json")!

        MapView(styleURL: demoTilesURL)
            .ignoresSafeArea(.all)
            .previewDisplayName("Vanilla Map")

        // For a larger selection of previews,
        // check out the Examples directory, which
        // has a wide variety of previews,
        // organized into (hopefully) useful groups
    }
}
