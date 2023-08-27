//
//  SwiftUIView.swift
//  
//
//  Created by Ian Wagner on 2023-08-15.
//

import SwiftUI
import InternalUtils
import Mapbox
import MapLibreSwiftDSL


public struct MapView: UIViewRepresentable {
    // TODO: Support MGLStyle as well; having a DSL for that would be nice
    enum MapStyleSource {
        case url(URL)
    }

    public enum Camera {
        case centerAndZoom(CLLocationCoordinate2D, Double?)
    }

    var camera: Binding<Camera>?

    let styleSource: MapStyleSource
    let userLayers: [StyleLayerDefinition]

    public init(styleURL: URL, camera: Binding<Camera>? = nil, @MapViewContentBuilder _ makeMapContent: () -> [StyleLayerDefinition] = { [] }) {
        self.styleSource = .url(styleURL)
        self.camera = camera

        userLayers = makeMapContent()
    }

    public init(styleURL: URL, initialCamera: Camera, @MapViewContentBuilder _ makeMapContent: () -> [StyleLayerDefinition] = { [] }) {
        self.init(styleURL: styleURL, camera: .constant(initialCamera), makeMapContent)
    }

    public class Coordinator: NSObject, MGLMapViewDelegate {
        private var styleSource: MapStyleSource
        private var userLayers: [StyleLayerDefinition]

        init(styleSource: MapStyleSource, userLayers: [StyleLayerDefinition]) {
            self.styleSource = styleSource
            self.userLayers = userLayers
        }

        // MARK: MGLMapViewDelegate

        public func mapView(_ mapView: MGLMapView, didFinishLoading mglStyle: MGLStyle) {
            addLayers(to: mglStyle)
        }

        func updateStyleSource(_ source: MapStyleSource, mapView: MGLMapView) {
            switch (source, self.styleSource) {
            case (.url(let newURL), .url(let oldURL)):
                if newURL != oldURL {
                    mapView.styleURL = newURL
                }
            }
        }

        public func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
            // TODO: Two-way camera binding
        }

        // MARK: Coordinator API

        func updateLayers(_ newLayers: [StyleLayerDefinition], mapView: MGLMapView) {
            // Remove old layers.
            // DISCUSS: Inefficient, but probably robust on the *layers* side.
            // TODO: Extract this out into a separate function or three...
            // Try to reuse DSL-defined sources if possible (they are the same type)!
            if let style = mapView.style {
                var sourcesToRemove = Set<String>()
                for layer in userLayers {
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
                    }
                }
            }

            // Set the new user-defined layers
            self.userLayers = newLayers

            // If the style is loaded, add the new layers to it.
            // Otherwise, this will get invoked automatically by the style didFinishLoading callback
            if let style = mapView.style {
                addLayers(to: style)
            }
        }

        func addLayers(to mglStyle: MGLStyle) {
            for layerSpec in userLayers {
                // DISCUSS: What preventions should we try to put in place against the user accidentally adding the same layer twice?
                let newLayer = layerSpec.makeStyleLayer(style: mglStyle).makeMGLStyleLayer()

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

    public func makeUIView(context: Context) -> MGLMapView {
        // Create the map view
        let mapView = MGLMapView(frame: .zero)
        mapView.delegate = context.coordinator

        switch styleSource {
        case .url(let styleURL):
            mapView.styleURL = styleURL
        }

        updateMapCamera(mapView, animated: false)

        // TODO: Make this settable via a modifier
        mapView.logoView.isHidden = true

        return mapView
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(
            styleSource: styleSource,
            userLayers: userLayers
        )
    }

    public func updateUIView(_ mapView: MGLMapView, context: Context) {
        context.coordinator.updateStyleSource(styleSource, mapView: mapView)
        context.coordinator.updateLayers(userLayers, mapView: mapView)

        updateMapCamera(mapView, animated: true)
    }

    private func updateMapCamera(_ mapView: MGLMapView, animated: Bool) {
        if let camera = self.camera {
            switch camera.wrappedValue {
            case .centerAndZoom(let center, let zoom):
                if let z = zoom {
                    mapView.setCenter(center, zoomLevel: z, animated: animated)
                } else {
                    mapView.setCenter(center, animated: animated)
                }
            }
        }
    }
}

@resultBuilder
public enum MapViewContentBuilder {
    public static func buildBlock(_ layers: StyleLayerDefinition...) -> [StyleLayerDefinition] {
        return layers
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        let demoTilesURL = URL(string: "https://demotiles.maplibre.org/style.json")!

        MapView(styleURL: demoTilesURL)
            .edgesIgnoringSafeArea(.all)
            .previewDisplayName("Vanilla Map")

        // For a larger selection of previews,
        // check out the Examples target, which
        // has a wide variety of previews,
        // organized into (hopefully) useful groups
    }
}
