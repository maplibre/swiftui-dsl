import XCTest
import CoreLocation
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
    
    // TODO: Add additional camera tests once behaviors are added (e.g. rect)
    
}
