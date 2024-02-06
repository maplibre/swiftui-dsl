import XCTest
import CoreLocation
@testable import MapLibreSwiftUI

final class CameraStateTests: XCTestCase {

    func testCenterCameraState() {
        let expectedCoordinate = CLLocationCoordinate2D(latitude: 12.3, longitude: 23.4)
        let state: CameraState = .centered(onCenter: expectedCoordinate)
        XCTAssertEqual(state, .centered(onCenter: CLLocationCoordinate2D(latitude: 12.3, longitude: 23.4)))
    }
    
    func testTrackingUserLocation() {
        let state: CameraState = .trackingUserLocation
        XCTAssertEqual(state, .trackingUserLocation)
    }
    
    func testTrackingUserLocationWithHeading() {
        let state: CameraState = .trackingUserLocationWithHeading
        XCTAssertEqual(state, .trackingUserLocationWithHeading)
    }
    
    func testTrackingUserLocationWithCourse() {
        let state: CameraState = .trackingUserLocationWithCourse
        XCTAssertEqual(state, .trackingUserLocationWithCourse)
    }
    
    func testRect() {
        let northeast = CLLocationCoordinate2D(latitude: 12.3, longitude: 23.4)
        let southwest = CLLocationCoordinate2D(latitude: 34.5, longitude: 45.6)
        
        let state: CameraState = .rect(northeast: northeast, southwest: southwest)
        XCTAssertEqual(state, .rect(northeast: northeast, southwest: southwest))
    }
    
}
