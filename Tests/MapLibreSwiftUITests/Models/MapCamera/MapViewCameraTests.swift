import CoreLocation
import MapLibre
import XCTest
@testable import MapLibreSwiftUI

final class MapViewCameraTests: XCTestCase {
    func testCenterCamera() {
        let expectedCoordinate = CLLocationCoordinate2D(latitude: 12.3, longitude: 23.4)
        let pitch: CameraPitch = .freeWithinRange(minimum: 12, maximum: 34)
        let direction: CLLocationDirection = 23

        let camera = MapViewCamera.center(expectedCoordinate, zoom: 12, pitch: pitch, direction: direction)

        XCTAssertEqual(camera.state, .centered(onCoordinate: expectedCoordinate))
        XCTAssertEqual(camera.zoom, 12)
        XCTAssertEqual(camera.pitch, pitch)
        XCTAssertEqual(camera.direction, direction)
    }

    func testTrackingUserLocation() {
        let pitch: CameraPitch = .freeWithinRange(minimum: 12, maximum: 34)
        let camera = MapViewCamera.trackUserLocation(pitch: pitch)

        XCTAssertEqual(camera.state, .trackingUserLocation)
        XCTAssertEqual(camera.zoom, 10)
        XCTAssertEqual(camera.pitch, pitch)
        XCTAssertEqual(camera.direction, 0)
    }

    func testTrackUserLocationWithCourse() {
        let pitch: CameraPitch = .freeWithinRange(minimum: 12, maximum: 34)
        let camera = MapViewCamera.trackUserLocationWithCourse(zoom: 18, pitch: pitch)

        XCTAssertEqual(camera.state, .trackingUserLocationWithCourse)
        XCTAssertEqual(camera.zoom, 18)
        XCTAssertEqual(camera.pitch, pitch)
        XCTAssertEqual(camera.direction, 0)
    }

    func testTrackUserLocationWithHeading() {
        let camera = MapViewCamera.trackUserLocationWithHeading()

        XCTAssertEqual(camera.state, .trackingUserLocationWithHeading)
        XCTAssertEqual(camera.zoom, 10)
        XCTAssertEqual(camera.pitch, .free)
        XCTAssertEqual(camera.direction, 0)
    }

    func testBoundingBox() {
        let southwest = CLLocationCoordinate2D(latitude: 24.6056011, longitude: 46.67369842529297)
        let northeast = CLLocationCoordinate2D(latitude: 24.6993808, longitude: 46.7709285)
        let bounds = MLNCoordinateBounds(sw: southwest, ne: northeast)
        let camera = MapViewCamera.boundingBox(bounds)

        XCTAssertEqual(
            camera.state,
            .rect(boundingBox: bounds, edgePadding: .init(top: 20, left: 20, bottom: 20, right: 20))
        )
        XCTAssertEqual(camera.zoom, 1)
        XCTAssertEqual(camera.pitch, .free)
        XCTAssertEqual(camera.direction, 0)
    }

    // TODO: Add additional camera tests once behaviors are added (e.g. rect)
}
