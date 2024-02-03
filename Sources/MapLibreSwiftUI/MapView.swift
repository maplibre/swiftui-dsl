import SwiftUI
import InternalUtils
import MapLibre
import MapLibreSwiftDSL

public struct MapView: UIViewRepresentable {
    
    @Binding var camera: MapViewCamera

    let styleSource: MapStyleSource
    let userLayers: [StyleLayerDefinition]
    var gestures = [MapGesture]()
    
    /// 'Escape hatch' to MLNMapView until we have more modifiers.
    /// See ``unsafeMapViewModifier(_:)``
    var unsafeMapViewModifier: ((MLNMapView) -> Void)?

    public init(
        styleURL: URL,
        camera: Binding<MapViewCamera> = .constant(.default()),
        @MapViewContentBuilder _ makeMapContent: () -> [StyleLayerDefinition] = { [] }
    ) {
        self.styleSource = .url(styleURL)
        self._camera = camera
        userLayers = makeMapContent()
    }

    public init(
        styleURL: URL,
        constantCamera: MapViewCamera,
        @MapViewContentBuilder _ makeMapContent: () -> [StyleLayerDefinition] = { [] }
    ) {
        self.init(styleURL: styleURL, 
                  camera: .constant(constantCamera),
                  makeMapContent)
    }
    
    public func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(
            parent: self,
            onGestureEnd: { processGestureEnd($0, $1) }
        )
    }
    
    public func makeUIView(context: Context) -> MLNMapView {
        // Create the map view
        let mapView = MLNMapView(frame: .zero)
        mapView.delegate = context.coordinator
        context.coordinator.mapView = mapView

        switch styleSource {
        case .url(let styleURL):
            mapView.styleURL = styleURL
        }

        context.coordinator.updateCamera(mapView: mapView,
                                         camera: $camera.wrappedValue,
                                         animated: false)
        
        // TODO: Make this settable via a modifier
        mapView.logoView.isHidden = true
        
        // Gesture recogniser setup
        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(context.coordinator.captureGesture(_:))
        )
        mapView.addGestureRecognizer(tapGesture)
   
        let longPressGesture = UILongPressGestureRecognizer(
            target: context.coordinator,
            action: #selector(context.coordinator.captureGesture(_:))
        )
        mapView.addGestureRecognizer(longPressGesture)
        
        return mapView
    }
    
    public func updateUIView(_ mapView: MLNMapView, context: Context) {
        context.coordinator.parent = self
        
        // MARK: Modifiers
        unsafeMapViewModifier?(mapView)
        
        // MARK: End Modifiers
        
        // FIXME: This should be a more selective update
        context.coordinator.updateStyleSource(styleSource, mapView: mapView)
        context.coordinator.updateLayers(mapView: mapView)
        
        // FIXME: This isn't exactly telling us if the *map* is loaded, and the docs for setCenter say it needs to be.
        let isStyleLoaded = mapView.style != nil

        context.coordinator.updateCamera(mapView: mapView,
                                         camera: $camera.wrappedValue,
                                         animated: isStyleLoaded)
    }
    
    /// Runs on gesture ended.
    ///
    /// Note: Some gestures may need additional behaviors for different gesture.states.
    ///
    /// - Parameters:
    ///   - mapView: The MapView emitting the gesture. This is used to calculate the point and coordinate of the gesture.
    ///   - sender: The UIGestureRecognizer
    private func processGestureEnd(_ mapView: MLNMapView, _ sender: UIGestureRecognizer) {
        guard sender.state == .ended else {
            return
        }
        
        let point = sender.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        
        switch sender {
        case is UITapGestureRecognizer:
            for gesture in gestures.filter({ $0.method == .tap }) {
                gesture.action(
                    MapGestureContext(gesture: gesture.method,
                                      point: point,
                                      coordinate: coordinate,
                                      numberOfTaps: sender.numberOfTouches)
                )
            }
        case is UILongPressGestureRecognizer:
            for gesture in gestures.filter({ $0.method == .longPress }) {
                gesture.action(
                    MapGestureContext(gesture: gesture.method,
                                      point: point,
                                      coordinate: coordinate,
                                      numberOfTaps: sender.numberOfTouches)
                )
            }
        default:
            print("Log unhandled gesture")
        }
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
