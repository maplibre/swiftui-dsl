import MapLibreSwiftDSL
import SnapshotTesting
import XCTest
@testable import MapLibreSwiftUI

final class MapControlsTests: XCTestCase {
    @MainActor
    func testEmptyControls() {
        assertView {
            MapView(styleURL: demoTilesURL)
                .mapControls {
                    // No controls
                }
        }
    }

    @MainActor
    func testLogoOnly() {
        assertView {
            MapView(styleURL: demoTilesURL)
                .mapControls {
                    LogoView()
                }
        }
    }

    @MainActor
    func testLogoChangePosition() {
        assertView {
            MapView(styleURL: demoTilesURL)
                .mapControls {
                    LogoView()
                        .position(.topLeft)
                }
        }
    }

    @MainActor
    func testCompassOnly() {
        assertView {
            MapView(styleURL: demoTilesURL)
                .mapControls {
                    CompassView()
                }
        }
    }

    @MainActor
    func testCompassChangePosition() {
        assertView {
            MapView(styleURL: demoTilesURL)
                .mapControls {
                    CompassView()
                        .position(.topLeft)
                }
        }
    }

    @MainActor
    func testAttributionOnly() {
        assertView {
            MapView(styleURL: demoTilesURL)
                .mapControls {
                    AttributionButton()
                }
        }
    }

    @MainActor
    func testAttributionChangePosition() {
        assertView {
            MapView(styleURL: demoTilesURL)
                .mapControls {
                    AttributionButton()
                        .position(.topLeft)
                }
        }
    }
}
