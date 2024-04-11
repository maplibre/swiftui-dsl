import XCTest
@testable import MapLibreSwiftUI

final class MapGestureTests: XCTestCase {
    func testTapGestureDefaults() {
        let gesture = MapGesture(method: .tap(),
                                 onChange: .context { _ in

                                 })

        XCTAssertEqual(gesture.method, .tap())
        XCTAssertNil(gesture.gestureRecognizer)
    }

    func testTapGesture() {
        let gesture = MapGesture(method: .tap(numberOfTaps: 3),
                                 onChange: .context { _ in

                                 })

        XCTAssertEqual(gesture.method, .tap(numberOfTaps: 3))
        XCTAssertNil(gesture.gestureRecognizer)
    }

    func testLongPressGestureDefaults() {
        let gesture = MapGesture(method: .longPress(),
                                 onChange: .context { _ in

                                 })

        XCTAssertEqual(gesture.method, .longPress())
        XCTAssertNil(gesture.gestureRecognizer)
    }

    func testLongPressGesture() {
        let gesture = MapGesture(method: .longPress(minimumDuration: 3),
                                 onChange: .context { _ in

                                 })

        XCTAssertEqual(gesture.method, .longPress(minimumDuration: 3))
        XCTAssertNil(gesture.gestureRecognizer)
    }
}
