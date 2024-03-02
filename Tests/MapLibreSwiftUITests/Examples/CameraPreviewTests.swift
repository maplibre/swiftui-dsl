import SnapshotTesting
import XCTest
@testable import MapLibreSwiftUI

final class CameraPreviewTests: XCTestCase {
    func testCameraPreview() {
        assertView(named: "CameraPreview") {
            CameraDirectManipulationPreview(
                styleURL: URL(string: "https://demotiles.maplibre.org/style.json")!
            )
        }
    }
}
