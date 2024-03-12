import CoreLocation
import SnapshotTesting
import XCTest
@testable import MapLibreSwiftUI

final class CameraStateTests: XCTestCase {
    let coordinate = CLLocationCoordinate2D(latitude: 12.3, longitude: 23.4)

    func testCenterCameraState() {
        let state: CameraState = .centered(onCoordinate: coordinate)
        XCTAssertEqual(state, .centered(onCoordinate: coordinate))
        assertSnapshot(of: state, as: .description)
    }

    func testTrackingUserLocation() {
        let state: CameraState = .trackingUserLocation
        XCTAssertEqual(state, .trackingUserLocation)
        assertSnapshot(of: state, as: .description)
    }

    func testTrackingUserLocationWithHeading() {
        let state: CameraState = .trackingUserLocationWithHeading
        XCTAssertEqual(state, .trackingUserLocationWithHeading)
        assertSnapshot(of: state, as: .description)
    }

    func testTrackingUserLocationWithCourse() {
        let state: CameraState = .trackingUserLocationWithCourse
        XCTAssertEqual(state, .trackingUserLocationWithCourse)
        assertSnapshot(of: state, as: .description)
    }

    func testRect() {
        let northeast = CLLocationCoordinate2D(latitude: 12.3, longitude: 23.4)
        let southwest = CLLocationCoordinate2D(latitude: 34.5, longitude: 45.6)

        let state: CameraState = .rect(northeast: northeast, southwest: southwest)
        XCTAssertEqual(state, .rect(northeast: northeast, southwest: southwest))
        assertSnapshot(of: state, as: .description)
    }
}
