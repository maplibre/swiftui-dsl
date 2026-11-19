import MapLibre
import MapLibreSwiftDSL
import Mockable
import XCTest
@testable import MapLibreSwiftUI

@MainActor
final class MapViewCoordinatorLayerTests: XCTestCase {
    private var styleLayers: MockStyleLayerCoordinating!
    private var coordinator: MapViewCoordinator<MLNMapViewController>!

    override func setUp() async throws {
        styleLayers = MockStyleLayerCoordinating()
        given(styleLayers).update(.any, in: .any).willReturn()
        given(styleLayers).addAll(.any, to: .any).willReturn()

        let mapView = MapView<MLNMapViewController>(styleURL: URL(string: "https://maplibre.org")!) {
            BackgroundLayer(identifier: "background")
        }
        coordinator = MapViewCoordinator(
            parent: mapView,
            onGesture: { _, _ in },
            onViewProxyChanged: { _ in },
            proxyUpdateMode: .onFinish,
            styleLayers: styleLayers
        )
    }

    func testUpdateLayersGivesTheLayersOfTheMapViewAndTheStyle() {
        let mapView = MLNMapView()

        coordinator.updateLayers(mapView: mapView)

        verify(styleLayers)
            .update(.matching { $0.map(\.identifier) == ["background"] }, in: .value(mapView.style))
            .called(1)
        verify(styleLayers).addAll(.any, to: .any).called(0)
    }

    func testStyleLoadAddsAllTheLayersOfTheMapView() async throws {
        let map = try await LoadedMap.load()

        coordinator.mapView(MLNMapView(), didFinishLoading: map.style)

        verify(styleLayers)
            .addAll(.matching { $0.map(\.identifier) == ["background"] }, to: .value(map.style))
            .called(1)
        verify(styleLayers).update(.any, in: .any).called(0)
    }
}
