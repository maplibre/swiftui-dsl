import CoreLocation
import XCTest
@testable import MapLibreSwiftUI

final class CameraStateTests: XCTestCase {
    func testCenterCameraState() {
        let expectedCoordinate = CLLocationCoordinate2D(latitude: 12.3, longitude: 23.4)
        let state: CameraState = .centered(onCoordinate: expectedCoordinate)
        XCTAssertEqual(state, .centered(onCoordinate: CLLocationCoordinate2D(latitude: 12.3, longitude: 23.4)))
        XCTAssertEqual(
            String(describing: state),
            "CameraState.centered(onCoordinate: CLLocationCoordinate2D(latitude: 12.3, longitude: 23.4)"
        )
    }

    func testTrackingUserLocation() {
        let state: CameraState = .trackingUserLocation
        XCTAssertEqual(state, .trackingUserLocation)
        XCTAssertEqual(String(describing: state), "CameraState.trackingUserLocation")
    }

    func testTrackingUserLocationWithHeading() {
        let state: CameraState = .trackingUserLocationWithHeading
        XCTAssertEqual(state, .trackingUserLocationWithHeading)
        XCTAssertEqual(String(describing: state), "CameraState.trackingUserLocationWithHeading")
    }

    func testTrackingUserLocationWithCourse() {
        let state: CameraState = .trackingUserLocationWithCourse
        XCTAssertEqual(state, .trackingUserLocationWithCourse)
        XCTAssertEqual(String(describing: state), "CameraState.trackingUserLocationWithCourse")
    }

    func testRect() {
        let northeast = CLLocationCoordinate2D(latitude: 12.3, longitude: 23.4)
        let southwest = CLLocationCoordinate2D(latitude: 34.5, longitude: 45.6)

        let state: CameraState = .rect(northeast: northeast, southwest: southwest)
        XCTAssertEqual(state, .rect(northeast: northeast, southwest: southwest))
        XCTAssertEqual(
            String(describing: state),
            "CameraState.rect(northeast: CLLocationCoordinate2D(latitude: 12.3, longitude: 23.4), southwest: CLLocationCoordinate2D(latitude: 34.5, longitude: 45.6))"
        )
    }
}
