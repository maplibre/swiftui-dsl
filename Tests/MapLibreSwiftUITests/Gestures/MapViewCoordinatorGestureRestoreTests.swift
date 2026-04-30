import MapLibre
import XCTest
@testable import MapLibreSwiftUI

final class MapViewCoordinatorGestureRestoreTests: XCTestCase {
    @MainActor
    func testRestoreAttachesPrePopulatedGesturesAfterIdentityRebuild() throws {
        // Simulate the `.id(...)` rebuild: the gesture modifier (and its
        // manager) outlives the MapView, so by the time a new coordinator's
        // `updateUIViewController` runs, the manager already holds gestures
        // registered before the coordinator existed.
        let mapView = try MapView(styleURL: XCTUnwrap(URL(string: "https://maplibre.org")))
        let coordinator = mapView.makeCoordinator()
        let mlnMapView = MLNMapView()
        coordinator.mapView = mlnMapView

        let tap = MapGesture(method: .tap(numberOfTaps: 1), onChange: .context { _ in })

        XCTAssertEqual(coordinator.managedGestureRecognizers.count, 0)

        coordinator.restoreGestures(on: mlnMapView, gestures: [tap])

        XCTAssertEqual(coordinator.managedGestureRecognizers.count, 1)
        XCTAssertTrue(coordinator.managedGestureRecognizers.first is UITapGestureRecognizer)
    }

    @MainActor
    func testRestoreIsNoOpWhenAlreadyInSync() throws {
        let mapView = try MapView(styleURL: XCTUnwrap(URL(string: "https://maplibre.org")))
        let coordinator = mapView.makeCoordinator()
        let mlnMapView = MLNMapView()
        coordinator.mapView = mlnMapView

        let tap = MapGesture(method: .tap(numberOfTaps: 1), onChange: .context { _ in })
        coordinator.syncGestures(on: mlnMapView, gestures: [tap])
        let attachedRecognizer = coordinator.managedGestureRecognizers.first

        coordinator.restoreGestures(on: mlnMapView, gestures: [tap])

        XCTAssertEqual(coordinator.managedGestureRecognizers.count, 1)
        XCTAssertTrue(coordinator.managedGestureRecognizers.first === attachedRecognizer,
                      "restore should not replace the recognizer when counts already match")
    }
}
