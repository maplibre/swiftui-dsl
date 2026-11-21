import CoreLocation
import Foundation
import MapLibre
import Testing
@testable import MapLibreSwiftUI

@MainActor
struct MapUserLocationTests {
    /// Browsing needs a marker without an implicit follow camera or another location source.
    @Test("Showing location uses the installed manager without starting tracking")
    func showingLocationUsesInstalledManagerWithoutTracking() throws {
        let manager = RecordingLocationManager()
        let map = MLNMapView()
        map.locationManager = manager
        let coordinator = try makeCoordinator()

        coordinator.updateUserLocationVisibility(true, on: map)

        #expect(map.showsUserLocation)
        #expect(map.userTrackingMode == .none)
        #expect(map.locationManager === manager)
        #expect(manager.locationStarts == 1)
        #expect(map.shouldRequestAuthorizationToUseLocationServices)
    }

    /// Unrelated SwiftUI updates must not restart a manager Native stopped after denial.
    @Test("Unchanged visibility respects Native shutdown after a location error")
    func unchangedVisibilityRespectsLocationErrorShutdown() throws {
        let map = MLNMapView()
        let manager = RecordingLocationManager()
        map.locationManager = manager
        let coordinator = try makeCoordinator()
        coordinator.updateUserLocationVisibility(true, on: map)
        manager.delegate?.locationManager(manager, didFailWithError: CLError(.denied))
        #expect(!map.showsUserLocation)
        let starts = manager.locationStarts

        coordinator.updateUserLocationVisibility(true, on: map)
        #expect(!map.showsUserLocation)
        #expect(manager.locationStarts == starts)

        coordinator.updateUserLocationVisibility(false, on: map)
        coordinator.updateUserLocationVisibility(true, on: map)
        #expect(map.showsUserLocation)
        #expect(manager.locationStarts == starts + 1)
    }

    private func makeCoordinator() throws -> MapViewCoordinator<MLNMapViewController> {
        let url = try #require(URL(string: "https://maplibre.org"))
        return MapViewCoordinator(parent: MapView(styleURL: url), onGesture: { _, _ in },
                                  onViewProxyChanged: { _ in }, proxyUpdateMode: .onFinish)
    }
}

@MainActor
private final class RecordingLocationManager: NSObject, @preconcurrency MLNLocationManager {
    weak var delegate: (any MLNLocationManagerDelegate)?
    var headingOrientation: CLDeviceOrientation = .portrait
    var authorizationStatus: CLAuthorizationStatus = .authorizedWhenInUse
    var locationStarts = 0
    func requestWhenInUseAuthorization() {}
    func requestAlwaysAuthorization() {}
    func startUpdatingLocation() {
        locationStarts += 1
    }

    func stopUpdatingLocation() {}
    func startUpdatingHeading() {}
    func stopUpdatingHeading() {}
    func dismissHeadingCalibrationDisplay() {}
}
