import InternalUtils
import MapLibre
import MapLibreSwiftDSL
import SwiftUI

public struct MapView: UIViewRepresentable {
    @Binding var camera: MapViewCamera

    let styleSource: MapStyleSource
    let userLayers: [StyleLayerDefinition]

    var gestures = [MapGesture]()
    var onStyleLoaded: ((MLNStyle) -> Void)?

    public var mapViewContentInset: UIEdgeInsets = .zero
    public var isLogoViewHidden = false
    public var isCompassViewHidden = false

    /// 'Escape hatch' to MLNMapView until we have more modifiers.
    /// See ``unsafeMapViewModifier(_:)``
    var unsafeMapViewModifier: ((MLNMapView) -> Void)?

    private var locationManager: MLNLocationManager?

    public init(
        styleURL: URL,
        camera: Binding<MapViewCamera> = .constant(.default()),
        locationManager: MLNLocationManager? = nil,
        @MapViewContentBuilder _ makeMapContent: () -> [StyleLayerDefinition] = { [] }
    ) {
        styleSource = .url(styleURL)
        _camera = camera
        userLayers = makeMapContent()
        self.locationManager = locationManager
    }

    public func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(
            parent: self,
            onGesture: { processGesture($0, $1) }
        )
    }

    public func makeUIView(context: Context) -> MLNMapView {
        // Create the map view
        let mapView = MLNMapView(frame: .zero)
        mapView.delegate = context.coordinator
        context.coordinator.mapView = mapView

        applyModifiers(mapView, runUnsafe: false)

        mapView.locationManager = locationManager

        switch styleSource {
        case let .url(styleURL):
            mapView.styleURL = styleURL
        }

        context.coordinator.updateCamera(mapView: mapView,
                                         camera: $camera.wrappedValue,
                                         animated: false)

        // Link the style loaded to the coordinator that emits the delegate event.
        context.coordinator.onStyleLoaded = onStyleLoaded

        // Add all gesture recognizers
        for gesture in gestures {
            registerGesture(mapView, context, gesture: gesture)
        }

        return mapView
    }

    public func updateUIView(_ mapView: MLNMapView, context: Context) {
        context.coordinator.parent = self

        applyModifiers(mapView, runUnsafe: true)

        // FIXME: This should be a more selective update
        context.coordinator.updateStyleSource(styleSource, mapView: mapView)
        context.coordinator.updateLayers(mapView: mapView)

        // FIXME: This isn't exactly telling us if the *map* is loaded, and the docs for setCenter say it needs to be.
        let isStyleLoaded = mapView.style != nil

        context.coordinator.updateCamera(mapView: mapView,
                                         camera: $camera.wrappedValue,
                                         animated: isStyleLoaded)
    }

    private func applyModifiers(_ mapView: MLNMapView, runUnsafe: Bool) {
        mapView.contentInset = mapViewContentInset

        mapView.logoView.isHidden = isLogoViewHidden
        mapView.compassView.isHidden = isCompassViewHidden

        if runUnsafe {
            unsafeMapViewModifier?(mapView)
        }
    }
}

extension MapView {
    func mapViewContentInset(_ inset: UIEdgeInsets) -> Self {
        var result = self

        result.mapViewContentInset = inset

        return result
    }

    func hideLogoView() -> Self {
        var result = self

        result.isLogoViewHidden = true

        return result
    }

    func hideCompassView() -> Self {
        var result = self

        result.isCompassViewHidden = true

        return result
    }
}

#Preview {
    MapView(styleURL: demoTilesURL)
        .ignoresSafeArea(.all)
        .previewDisplayName("Vanilla Map")

    // For a larger selection of previews,
    // check out the Examples directory, which
    // has a wide variety of previews,
    // organized into (hopefully) useful groups
}
