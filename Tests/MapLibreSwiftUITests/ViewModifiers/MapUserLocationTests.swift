import CoreLocation
import Foundation
import MapLibre
import Testing
@testable import MapLibreSwiftUI

@MainActor
struct MapUserLocationTests {
    @Test("Showing location uses the installed manager without starting tracking")
    func showingLocationUsesInstalledManagerWithoutTracking() throws {
        let manager = RecordingLocationManager()
        let map = MLNMapView()
        map.locationManager = manager
        let coordinator = try makeCoordinator()

        coordinator.updateUserLocationVisibility(true, on: map)

        // An app can show the user location annotation while keeping the camera
        // centered on a route preview. Setting userTrackingMode to .follow would
        // instead let location updates move the camera.
        #expect(map.showsUserLocation)
        #expect(map.userTrackingMode == .none)

        // An app can supply simulated locations to MLNMapView. Showing the annotation
        // should use that source and leave permission requests under the existing policy.
        #expect(map.locationManager === manager)
        #expect(manager.locationStarts == 1)
        #expect(map.shouldRequestAuthorizationToUseLocationServices)
    }

    @Test("Unchanged visibility respects Native shutdown after a location error")
    func unchangedVisibilityRespectsLocationErrorShutdown() throws {
        let map = MLNMapView()
        let manager = RecordingLocationManager()
        map.locationManager = manager
        let coordinator = try makeCoordinator()
        coordinator.updateUserLocationVisibility(true, on: map)

        // MLNMapView clears showsUserLocation on .denied. The last value passed
        // to mapUserLocationVisible is still true, so the two values now differ.
        manager.delegate?.locationManager(manager, didFailWithError: CLError(.denied))
        #expect(!map.showsUserLocation)
        let starts = manager.locationStarts

        // SwiftUI can pass the same true value again during an unrelated update.
        // Reapplying it would restart the location updates MLNMapView just stopped.
        coordinator.updateUserLocationVisibility(true, on: map)
        #expect(!map.showsUserLocation)
        #expect(manager.locationStarts == starts)

        // A false-to-true change represents the app turning the annotation back on.
        // This catches implementations that suppress every later request after .denied.
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
