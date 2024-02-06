import XCTest
import MapLibre
@testable import MapLibreSwiftUI

final class CameraChangeReasonTests: XCTestCase {

    func testGestureOneFingerZoom() {
        let mlnReason: MLNCameraChangeReason = [.programmatic, .gestureOneFingerZoom]
        XCTAssertEqual(CameraChangeReason(mlnReason), .gestureOneFingerZoom)
    }

}
