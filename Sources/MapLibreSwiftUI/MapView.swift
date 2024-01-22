import SwiftUI
import InternalUtils
import MapLibre
import MapLibreSwiftDSL

public struct MapView: UIViewRepresentable {
    
    public private(set) var camera: Binding<MapViewCamera>

    let styleSource: MapStyleSource
    let userLayers: [StyleLayerDefinition]
    
    /// 'Escape hatch' to MLNMapView until we have more modifiers.
    /// See ``unsafeMapViewModifier(_:)``
    private var unsafeMapViewModifier: ((MLNMapView) -> Void)?

    public init(
        styleURL: URL,
        camera: Binding<MapViewCamera> = .constant(.default()),
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
    
    /// Allows you to set properties of the underlying MLNMapView directly
    /// in cases where these have not been ported to DSL yet.
    /// Use this function to modify various properties of the MLNMapView instance.
    /// For example, you can enable the display of the user's location on the map by setting `showUserLocation` to true.
    ///
    /// This is an 'escape hatch' back to the non-DSL world
    /// of MapLibre for features that have not been ported to DSL yet.
    /// Be careful not to use this to modify properties that are
    /// already ported to the DSL, like the camera for example, as your
    /// modifications here may break updates that occur with modifiers.
    ///
    /// - Parameter modifier: A closure that provides you with an MLNMapView so you can set properties.
    /// - Returns: A MapView with the modifications applied.
    ///
    /// Example:
    /// ```swift
    ///  MapView()
    ///     .mapViewModifier { mapView in
    ///         mapView.showUserLocation = true
    ///     }
    /// ```
    ///
    public func unsafeMapViewModifier(_ modifier: @escaping (MLNMapView) -> Void) -> MapView {
        var newMapView = self
        newMapView.unsafeMapViewModifier = modifier
        return newMapView
    }

    public class Coordinator: NSObject, MLNMapViewDelegate {
        var parent:  MapView

        // Storage of variables as they were previously; these are snapshot
        // every update cycle so we can avoid unnecessary updates
        private var snapshotUserLayers: [StyleLayerDefinition] = []
        private var snapshotCamera: MapViewCamera?
        
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
                self.parent.camera.wrappedValue = .center(mapView.centerCoordinate,
                                                          zoom:  mapView.zoomLevel)
            }
        }

        // MARK: - Coordinator API

        func updateCamera(mapView: MLNMapView, camera: MapViewCamera, animated: Bool) {
            guard camera != snapshotCamera else {
                // No action - camera has not changed.
                return
            }
            
            mapView.setCenter(camera.coordinate,
                              zoomLevel: camera.zoom,
                              direction: camera.course,
                              animated: animated)
            
            snapshotCamera = camera
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

    public func makeUIView(context: Context) -> MLNMapView {
        // Create the map view
        let mapView = MLNMapView(frame: .zero)
        mapView.delegate = context.coordinator

        switch styleSource {
        case .url(let styleURL):
            mapView.styleURL = styleURL
        }

        context.coordinator.updateCamera(mapView: mapView,
                                         camera: camera.wrappedValue,
                                         animated: false)
        
        // TODO: Make this settable via a modifier
        mapView.logoView.isHidden = true

        return mapView
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    public func updateUIView(_ mapView: MLNMapView, context: Context) {
        context.coordinator.parent = self
        
        unsafeMapViewModifier?(mapView)
        
        // FIXME: This should be a more selective update
        context.coordinator.updateStyleSource(styleSource, mapView: mapView)
        context.coordinator.updateLayers(mapView: mapView)
        
        // FIXME: This isn't exactly telling us if the *map* is loaded, and the docs for setCenter say it needs to be.
        let isStyleLoaded = mapView.style != nil

        context.coordinator.updateCamera(mapView: mapView,
                                         camera: camera.wrappedValue,
                                         animated: isStyleLoaded)
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
