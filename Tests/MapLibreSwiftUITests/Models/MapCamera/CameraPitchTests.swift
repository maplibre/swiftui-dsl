import XCTest
@testable import MapLibreSwiftUI

final class CameraPitchTests: XCTestCase {
    func testFreePitch() {
        let pitch: CameraPitchRange = .free
        XCTAssertEqual(pitch.rangeValue.lowerBound, 0)
        XCTAssertEqual(pitch.rangeValue.upperBound, 60)
    }

    func testRangePitch() {
        let pitch = CameraPitchRange.freeWithinRange(minimum: 9, maximum: 29)
        XCTAssertEqual(pitch.rangeValue.lowerBound, 9)
        XCTAssertEqual(pitch.rangeValue.upperBound, 29)
    }

    func testFixedPitch() {
        let pitch = CameraPitchRange.fixed(41)
        XCTAssertEqual(pitch.rangeValue.lowerBound, 41)
        XCTAssertEqual(pitch.rangeValue.upperBound, 41)
    }
}
