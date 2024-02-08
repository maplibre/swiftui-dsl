import XCTest
import MockableTest
import MapLibre
@testable import MapLibreSwiftUI

final class MapViewGestureTests: XCTestCase {

    let maplibreMapView = MLNMapView()
    let mapView = MapView(styleURL: URL(string: "https://maplibre.org")!)
    
    // MARK: Gesture View Modifiers
    
    func testMapViewOnTapGestureModifier() {
        let newMapView = mapView.onTapMapGesture { _ in }
        
        XCTAssertEqual(newMapView.gestures.first?.method, .tap())
    }
    
    func testMapViewOnLongPressGestureModifier() {
        let newMapView = mapView.onLongPressMapGesture { _ in }
        
        XCTAssertEqual(newMapView.gestures.first?.method, .longPress())
    }
    
    // MARK: Gesture Processing
    
    func testTapGesture() {
        let gesture = MapGesture(method: .tap(numberOfTaps: 2)) { _ in
            // No capture
        }
        
        let mockTapGesture = MockUIGestureRecognizerProtocol()
        
        given(mockTapGesture)
            .state.willReturn(.ended)
        
        given(mockTapGesture)
            .location(ofTouch: .value(1), in: .any)
            .willReturn(CGPoint(x: 10, y: 10))
        
        let result = mapView.processContextFromGesture(maplibreMapView,
                                                       gesture: gesture,
                                                       sender: mockTapGesture)
        
        XCTAssertEqual(result.gestureMethod, .tap(numberOfTaps: 2))
        XCTAssertEqual(result.point, CGPoint(x: 10, y: 10))
        
        // TODO: Delete this? The MLNMapView is technically converting something. Probably not reliably, but it could still be useful to track.
        XCTAssertEqual(result.coordinate.latitude, 15, accuracy: 1)
        XCTAssertEqual(result.coordinate.longitude, -15, accuracy: 1)
    }
    
    func testLongPressGesture() {
        let gesture = MapGesture(method: .longPress(minimumDuration: 1)) { _ in
            // No capture
        }
        
        let mockTapGesture = MockUIGestureRecognizerProtocol()
        
        given(mockTapGesture)
            .state.willReturn(.ended)
        
        given(mockTapGesture)
            .location(in: .any)
            .willReturn(CGPoint(x: 10, y: 10))
        
        let result = mapView.processContextFromGesture(maplibreMapView,
                                                       gesture: gesture,
                                                       sender: mockTapGesture)
        
        XCTAssertEqual(result.gestureMethod, .longPress(minimumDuration: 1))
        XCTAssertEqual(result.point, CGPoint(x: 10, y: 10))
        
        // TODO: Delete this? The MLNMapView is technically converting something. Probably not reliably, but it could still be useful to track.
        XCTAssertEqual(result.coordinate.latitude, 15, accuracy: 1)
        XCTAssertEqual(result.coordinate.longitude, -15, accuracy: 1)
    }
}
