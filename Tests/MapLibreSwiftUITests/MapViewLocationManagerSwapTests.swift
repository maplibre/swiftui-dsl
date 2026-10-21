import CoreLocation
import Foundation
import MapLibre
import SwiftUI
import Testing
@testable import MapLibreSwiftUI

/// Each test shows a real `MLNMapView` in a key window.
@MainActor
@Suite(.serialized)
struct MapViewLocationManagerSwapTests {
    @Test func swappedLocationManagerReportsToMapThatShowsUserLocation() async throws {
        let first = CLLocationCoordinate2D(latitude: 10, longitude: 10)
        let second = CLLocationCoordinate2D(latitude: 10.001, longitude: 10.001)
        let model = Model(
            locationManager: StaticLocationManager(initialLocation: CLLocation(
                latitude: first.latitude,
                longitude: first.longitude
            )),
            camera: .trackUserLocation(zoom: 15)
        )
        let map = try HostedMap(model: model)
        defer { map.close() }
        // MLNMapView ignores new locations while it flies the camera to the first one.
        try #require(
            await waitUntil { isClose(map.mapView?.centerCoordinate, to: first, tolerance: 1e-6) },
            "The camera does not follow the first location manager"
        )

        model.locationManager = StaticLocationManager(initialLocation: CLLocation(
            latitude: second.latitude,
            longitude: second.longitude
        ))

        let reachedSecond = await waitUntil {
            isClose(map.mapView?.userLocation?.location?.coordinate, to: second, tolerance: 1e-9)
        }
        #expect(reachedSecond, "The puck is at \(String(describing: map.mapView?.userLocation?.location?.coordinate))")
    }

    @Test func swappedLocationManagerStartsHeadingWhenFollowingWithHeading() async throws {
        let model = Model(locationManager: RecordingLocationManager(), camera: .trackUserLocationWithHeading())
        let map = try HostedMap(model: model)
        defer { map.close() }
        try #require(await waitUntil { map.mapView?.userTrackingMode == .followWithHeading })

        let swapped = RecordingLocationManager()
        model.locationManager = swapped

        let started = await waitUntil {
            swapped.startUpdatingLocationCount > 0 && swapped.startUpdatingHeadingCount > 0
        }
        #expect(started)
    }

    @Test func swappedLocationManagerStaysStoppedWhenMapHidesUserLocation() async throws {
        let model = Model(
            locationManager: RecordingLocationManager(),
            camera: .center(CLLocationCoordinate2D(latitude: 10, longitude: 10), zoom: 10)
        )
        let map = try HostedMap(model: model)
        defer { map.close() }
        try #require(await waitUntil { map.mapView != nil })
        try #require(map.mapView?.showsUserLocation == false, "The map shows the puck")

        let swapped = RecordingLocationManager()
        model.locationManager = swapped
        try await Task.sleep(nanoseconds: 500_000_000)

        try #require(map.mapView?.locationManager === swapped, "The map does not have the new manager")
        #expect(swapped.startUpdatingLocationCount == 0)
        #expect(swapped.startUpdatingHeadingCount == 0)
    }
}

// MARK: Helpers

@MainActor
private final class Model: ObservableObject {
    @Published var locationManager: (any MLNLocationManager)?
    @Published var camera: MapViewCamera

    init(locationManager: (any MLNLocationManager)?, camera: MapViewCamera) {
        self.locationManager = locationManager
        self.camera = camera
    }
}

/// A `MapView` in a key window, with access to its `MLNMapView`.
@MainActor
private final class HostedMap {
    private struct Host: View {
        @ObservedObject var model: Model
        let styleURL: URL
        let onMapView: (MLNMapView) -> Void

        var body: some View {
            MapView(styleURL: styleURL, camera: $model.camera, locationManager: model.locationManager)
                .unsafeMapViewControllerModifier { controller in
                    onMapView(controller.mapView)
                }
        }
    }

    private let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
    private(set) weak var mapView: MLNMapView?

    init(model: Model) throws {
        // An empty style keeps the test off the network. The location logic does not need tiles.
        let styleURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("MapViewLocationManagerSwapTests-empty-style.json")
        try Data(#"{"version":8,"sources":{},"layers":[]}"#.utf8).write(to: styleURL)

        let host = Host(model: model, styleURL: styleURL) { [weak self] in self?.mapView = $0 }
        window.rootViewController = UIHostingController(rootView: host)
        window.makeKeyAndVisible()
    }

    func close() {
        window.isHidden = true
        window.rootViewController = nil
    }
}

/// Counts the calls that `MLNMapView` makes, and never reports a location.
private final class RecordingLocationManager: NSObject, MLNLocationManager {
    var delegate: (any MLNLocationManagerDelegate)?
    var authorizationStatus: CLAuthorizationStatus = .authorizedWhenInUse
    var headingOrientation: CLDeviceOrientation = .portrait
    private(set) var startUpdatingLocationCount = 0
    private(set) var startUpdatingHeadingCount = 0

    func requestAlwaysAuthorization() {}
    func requestWhenInUseAuthorization() {}
    func startUpdatingLocation() {
        startUpdatingLocationCount += 1
    }

    func stopUpdatingLocation() {}
    func startUpdatingHeading() {
        startUpdatingHeadingCount += 1
    }

    func stopUpdatingHeading() {}
    func dismissHeadingCalibrationDisplay() {}
}

private func isClose(
    _ coordinate: CLLocationCoordinate2D?,
    to expected: CLLocationCoordinate2D,
    tolerance: CLLocationDegrees
) -> Bool {
    guard let coordinate else {
        return false
    }
    return abs(coordinate.latitude - expected.latitude) <= tolerance
        && abs(coordinate.longitude - expected.longitude) <= tolerance
}

/// Polls `condition` until it is true or `timeout` seconds pass.
///
/// The main actor suspends between polls, so main queue work such as location updates can run.
@MainActor
private func waitUntil(timeout: TimeInterval = 10, _ condition: () -> Bool) async -> Bool {
    let deadline = Date().addingTimeInterval(timeout)
    while Date() < deadline {
        if condition() {
            return true
        }
        try? await Task.sleep(nanoseconds: 50_000_000)
    }
    return condition()
}
