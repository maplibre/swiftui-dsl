import MapLibre
import Mockable
import XCTest
@testable import MapLibreSwiftUI

final class MapViewGestureTests: XCTestCase {
    let maplibreMapView = MLNMapView()

    @MainActor
    let mapView = MapView(styleURL: URL(string: "https://maplibre.org")!)

    // MARK: Gesture Processing

    @MainActor func testTapGesture() {
        let gesture = MapGesture(method: .tap(numberOfTaps: 2), onChange: .context { _ in
            // Do nothing
        })

        let mockTapGesture = MockUIGestureRecognizing()

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
        // This is what the un-rendered map view returns. We're simply testing it returns something.
        XCTAssertEqual(result.coordinate.latitude, 15, accuracy: 1)
        XCTAssertEqual(result.coordinate.longitude, -15, accuracy: 1)
    }

    @MainActor func testLongPressGesture() {
        let gesture = MapGesture(method: .longPress(minimumDuration: 1), onChange: .context { _ in
            // Do nothing
        })

        let mockTapGesture = MockUIGestureRecognizing()

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
        // This is what the un-rendered map view returns. We're simply testing it returns something.
        XCTAssertEqual(result.coordinate.latitude, 15, accuracy: 1)
        XCTAssertEqual(result.coordinate.longitude, -15, accuracy: 1)
    }
}
