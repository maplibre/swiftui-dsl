import MapLibreSwiftDSL
import SnapshotTesting
import XCTest
@testable import MapLibreSwiftUI

final class MapControlsTests: XCTestCase {
    func testEmptyControls() {
        assertView {
            MapView<MapViewController>(styleURL: demoTilesURL)
                .mapControls {
                    // No controls
                }
        }
    }

    func testLogoOnly() {
        assertView {
            MapView<MapViewController>(styleURL: demoTilesURL)
                .mapControls {
                    LogoView()
                }
        }
    }

    func testLogoChangePosition() {
        assertView {
            MapView<MapViewController>(styleURL: demoTilesURL)
                .mapControls {
                    LogoView()
                        .position(.topLeft)
                }
        }
    }

    func testCompassOnly() {
        assertView {
            MapView<MapViewController>(styleURL: demoTilesURL)
                .mapControls {
                    CompassView()
                }
        }
    }

    func testCompassChangePosition() {
        assertView {
            MapView<MapViewController>(styleURL: demoTilesURL)
                .mapControls {
                    CompassView()
                        .position(.topLeft)
                }
        }
    }

    func testAttributionOnly() {
        assertView {
            MapView<MapViewController>(styleURL: demoTilesURL)
                .mapControls {
                    AttributionButton()
                }
        }
    }

    func testAttributionChangePosition() {
        assertView {
            MapView<MapViewController>(styleURL: demoTilesURL)
                .mapControls {
                    AttributionButton()
                        .position(.topLeft)
                }
        }
    }
}
