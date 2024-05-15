import CoreLocation
import SnapshotTesting
import XCTest
@testable import MapLibreSwiftUI

final class CameraStateTests: XCTestCase {
    let coordinate = CLLocationCoordinate2D(latitude: 12.3, longitude: 23.4)

    func testCenterCameraState() {
        let state: CameraState = .centered(
            onCoordinate: coordinate,
            zoom: 4,
            pitch: 0,
            pitchRange: .free,
            direction: 42
        )
        XCTAssertEqual(state, .centered(onCoordinate: coordinate, zoom: 4, pitch: 0, pitchRange: .free, direction: 42))
        assertSnapshot(of: state, as: .description)
    }

    func testTrackingUserLocation() {
        let state: CameraState = .trackingUserLocation(zoom: 4, pitch: 0, pitchRange: .free, direction: 12)
        XCTAssertEqual(state, .trackingUserLocation(zoom: 4, pitch: 0, pitchRange: .free, direction: 12))
        assertSnapshot(of: state, as: .description)
    }

    func testTrackingUserLocationWithHeading() {
        let state: CameraState = .trackingUserLocationWithHeading(zoom: 4, pitch: 0, pitchRange: .free)
        XCTAssertEqual(state, .trackingUserLocationWithHeading(zoom: 4, pitch: 0, pitchRange: .free))
        assertSnapshot(of: state, as: .description)
    }

    func testTrackingUserLocationWithCourse() {
        let state: CameraState = .trackingUserLocationWithCourse(zoom: 4, pitch: 0, pitchRange: .free)
        XCTAssertEqual(state, .trackingUserLocationWithCourse(zoom: 4, pitch: 0, pitchRange: .free))
        assertSnapshot(of: state, as: .description)
    }

    func testRect() {
        let northeast = CLLocationCoordinate2D(latitude: 12.3, longitude: 23.4)
        let southwest = CLLocationCoordinate2D(latitude: 34.5, longitude: 45.6)

        let state: CameraState = .rect(boundingBox: .init(sw: southwest, ne: northeast))
        XCTAssertEqual(state, .rect(boundingBox: .init(sw: southwest, ne: northeast)))

        assertSnapshot(of: state, as: .description)
    }
}
