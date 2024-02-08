import XCTest
import MapLibre
@testable import MapLibreSwiftUI

final class CameraChangeReasonTests: XCTestCase {

    func testProgrammatic() {
        let mlnReason: MLNCameraChangeReason = [.programmatic]
        XCTAssertEqual(CameraChangeReason(mlnReason), .programmatic)
    }
    
    func testTransitionCancelled() {
        let mlnReason: MLNCameraChangeReason = [.transitionCancelled]
        XCTAssertEqual(CameraChangeReason(mlnReason), .transitionCancelled)
    }
    
    func testResetNorth() {
        let mlnReason: MLNCameraChangeReason = [.programmatic, .resetNorth]
        XCTAssertEqual(CameraChangeReason(mlnReason), .resetNorth)
    }
    
    func testGesturePan() {
        let mlnReason: MLNCameraChangeReason = [.gesturePan]
        XCTAssertEqual(CameraChangeReason(mlnReason), .gesturePan)
    }
    
    func testGesturePinch() {
        let mlnReason: MLNCameraChangeReason = [.gesturePinch]
        XCTAssertEqual(CameraChangeReason(mlnReason), .gesturePinch)
    }
    
    func testGestureRotate() {
        let mlnReason: MLNCameraChangeReason = [.gestureRotate]
        XCTAssertEqual(CameraChangeReason(mlnReason), .gestureRotate)
    }
    
    func testGestureTilt() {
        let mlnReason: MLNCameraChangeReason = [.programmatic, .gestureTilt]
        XCTAssertEqual(CameraChangeReason(mlnReason), .gestureTilt)
    }
    
    func testGestureZoomIn() {
        let mlnReason: MLNCameraChangeReason = [.gestureZoomIn, .programmatic, ]
        XCTAssertEqual(CameraChangeReason(mlnReason), .gestureZoomIn)
    }
    
    func testGestureZoomOut() {
        let mlnReason: MLNCameraChangeReason = [.programmatic, .gestureZoomOut]
        XCTAssertEqual(CameraChangeReason(mlnReason), .gestureZoomOut)
    }
    
    func testGestureOneFingerZoom() {
        let mlnReason: MLNCameraChangeReason = [.programmatic, .gestureOneFingerZoom]
        XCTAssertEqual(CameraChangeReason(mlnReason), .gestureOneFingerZoom)
    }
}
