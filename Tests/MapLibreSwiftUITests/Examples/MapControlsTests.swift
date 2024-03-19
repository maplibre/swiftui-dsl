import MapLibreSwiftDSL
import SnapshotTesting
import XCTest
@testable import MapLibreSwiftUI

final class MapControlsTests: XCTestCase {
    func testEmptyControls() {
        assertView {
            MapView(styleURL: demoTilesURL)
                .mapControls {
                    // No controls
                }
        }
    }

    func testLogoOnly() {
        assertView {
            MapView(styleURL: demoTilesURL)
                .mapControls {
                    LogoView()
                }
        }
    }

    func testLogoChangePosition() {
        assertView {
            MapView(styleURL: demoTilesURL)
                .mapControls {
                    LogoView()
                        .position(.topLeft)
                }
        }
    }

    func testCompassOnly() {
        assertView {
            MapView(styleURL: demoTilesURL)
                .mapControls {
                    CompassView()
                }
        }
    }

    func testCompassChangePosition() {
        assertView {
            MapView(styleURL: demoTilesURL)
                .mapControls {
                    CompassView()
                        .position(.topLeft)
                }
        }
    }
}
