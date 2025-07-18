import InternalUtils
import MapLibre
import MapLibreSwiftDSL
import SwiftUI

/// Identifies the activity this ``MapView`` is being used for. Useful for debugging purposes.
public enum MapActivity: Int, CustomStringConvertible {
    /// Navigation in a standard window. Default.
    case standard = 0
    /// Navigation in a CarPlay template.
    case carplay = 2025

    public var description: String {
        switch self {
        case .standard:
            "standard"
        case .carplay:
            "carplay"
        }
    }
}

public struct MapView<T: MapViewHostViewController>: UIViewControllerRepresentable {
    public typealias UIViewControllerType = T
    var cameraDisabled: Bool = false

    @Binding var camera: MapViewCamera

    let makeViewController: () -> T
    let styleSource: MapStyleSource
    let userLayers: [StyleLayerDefinition]

    var gestures = [MapGesture]()

    var onStyleLoaded: ((MLNStyle) -> Void)?
    var onViewProxyChanged: ((MapViewProxy) -> Void)?
    var proxyUpdateMode: ProxyUpdateMode?

    var mapViewContentInset: UIEdgeInsets?

    var unsafeMapViewControllerModifier: ((T) -> Void)?

    var controls: [MapControl] = [
        CompassView(),
        LogoView(),
        AttributionButton(),
    ]

    private var locationManager: MLNLocationManager?

    var clusteredLayers: [ClusterLayer]?

    let activity: MapActivity

    public init(
        makeViewController: @autoclosure @escaping () -> T,
        styleURL: URL,
        camera: Binding<MapViewCamera> = .constant(.default()),
        locationManager: MLNLocationManager? = nil,
        activity: MapActivity = .standard,
        @MapViewContentBuilder _ makeMapContent: () -> [StyleLayerDefinition] = { [] }
    ) {
        self.makeViewController = makeViewController
        styleSource = .url(styleURL)
        _camera = camera
        userLayers = makeMapContent()
        self.locationManager = locationManager
        self.activity = activity
    }

    public func makeCoordinator() -> MapViewCoordinator<T> {
        MapViewCoordinator<T>(
            parent: self,
            onGesture: { processGesture($0, $1) },
            onViewProxyChanged: { onViewProxyChanged?($0) },
            proxyUpdateMode: proxyUpdateMode ?? .onFinish
        )
    }

    public func makeUIViewController(context: Context) -> T {
        // Create the map view
        let controller = makeViewController()
        controller.mapView.delegate = context.coordinator
        context.coordinator.mapView = controller.mapView

        // Apply modifiers, suppressing camera update propagation (this messes with setting our initial camera as
        // content insets can trigger a change)
        applyModifiers(controller, runUnsafe: false)

        controller.mapView.locationManager = locationManager

        switch styleSource {
        case let .url(styleURL):
            controller.mapView.styleURL = styleURL
        }

        context.coordinator.applyCameraChangeFromStateUpdate(
            controller.mapView,
            camera: camera,
            animated: false
        )

        controller.mapView.locationManager = controller.mapView.locationManager

        // Link the style loaded to the coordinator that emits the delegate event.
        context.coordinator.onStyleLoaded = onStyleLoaded

        // Add all gesture recognizers
        for gesture in gestures {
            registerGesture(controller.mapView, context, gesture: gesture)
        }

        return controller
    }

    public func updateUIViewController(_ uiViewController: T, context: Context) {
        context.coordinator.parent = self

        applyModifiers(uiViewController, runUnsafe: true)

        // FIXME: This should be a more selective update
        context.coordinator.updateStyleSource(styleSource, mapView: uiViewController.mapView)
        context.coordinator.updateLayers(mapView: uiViewController.mapView)

        // FIXME: This isn't exactly telling us if the *map* is loaded, and the docs for setCenter say it needs to be.
        let isStyleLoaded = uiViewController.mapView.style != nil

        if cameraDisabled == false {
            context.coordinator.applyCameraChangeFromStateUpdate(
                uiViewController.mapView,
                camera: camera,
                animated: isStyleLoaded
            )
        }
    }

    @MainActor private func applyModifiers(_ mapViewController: T, runUnsafe: Bool) {
        if let mapViewContentInset {
            mapViewController.mapView.automaticallyAdjustsContentInset = false
            mapViewController.mapView.contentInset = mapViewContentInset
        }

        // Assume all controls are hidden by default (so that an empty list returns a map with no controls)
        mapViewController.mapView.logoView.isHidden = true
        mapViewController.mapView.compassView.isHidden = true
        mapViewController.mapView.attributionButton.isHidden = true

        // Apply each control configuration
        for control in controls {
            control.configureMapView(mapViewController.mapView)
        }

        if runUnsafe {
            unsafeMapViewControllerModifier?(mapViewController)
        }
    }
}

public extension MapView where T == MLNMapViewController {
    @MainActor
    init(
        styleURL: URL,
        camera: Binding<MapViewCamera> = .constant(.default()),
        locationManager: MLNLocationManager? = nil,
        activity: MapActivity = .standard,
        @MapViewContentBuilder _ makeMapContent: () -> [StyleLayerDefinition] = { [] }
    ) {
        self.init(
            makeViewController: {
                let vc = MLNMapViewController()
                vc.activity = activity
                return vc
            }(),
            styleURL: styleURL,
            camera: camera,
            locationManager: locationManager,
            activity: activity,
            makeMapContent
        )
    }
}

#Preview("Vanilla Map") {
    MapView(styleURL: demoTilesURL)
        .ignoresSafeArea(.all)

    // For a larger selection of previews,
    // check out the Examples directory, which
    // has a wide variety of previews,
    // organized into (hopefully) useful groups
}
