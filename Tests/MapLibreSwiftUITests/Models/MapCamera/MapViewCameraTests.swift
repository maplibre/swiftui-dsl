import CoreLocation
import MapLibre
import SnapshotTesting
import XCTest
@testable import MapLibreSwiftUI

@MainActor
final class MapViewCameraTests: XCTestCase {
    func testCenterCamera() {
        let camera = MapViewCamera.center(
            CLLocationCoordinate2D(latitude: 12.3, longitude: 23.4),
            zoom: 5,
            pitch: 12,
            direction: 23
        )

        assertSnapshot(of: camera, as: .dump)
    }

    func testTrackingUserLocation() {
        let pitch: CameraPitchRange = .freeWithinRange(minimum: 12, maximum: 34)
        let camera = MapViewCamera.trackUserLocation(zoom: 10, pitchRange: pitch)

        assertSnapshot(of: camera, as: .dump)
    }

    func testTrackUserLocationWithCourse() {
        let pitchRange: CameraPitchRange = .freeWithinRange(minimum: 12, maximum: 34)
        let camera = MapViewCamera.trackUserLocationWithCourse(zoom: 18, pitchRange: pitchRange)

        assertSnapshot(of: camera, as: .dump)
    }

    func testTrackUserLocationWithHeading() {
        let camera = MapViewCamera.trackUserLocationWithHeading(zoom: 10, pitch: 0)

        assertSnapshot(of: camera, as: .dump)
    }

    func testBoundingBox() {
        let southwest = CLLocationCoordinate2D(latitude: 24.6056011, longitude: 46.67369842529297)
        let northeast = CLLocationCoordinate2D(latitude: 24.6993808, longitude: 46.7709285)
        let bounds = MLNCoordinateBounds(sw: southwest, ne: northeast)
        let camera = MapViewCamera.boundingBox(bounds)

        assertSnapshot(of: camera, as: .dump)
    }
}
