import CoreLocation
import MapLibreSwiftDSL
import SnapshotTesting
import XCTest
@testable import MapLibreSwiftUI

final class MapControlsTests: XCTestCase {
    // NOTE: The map views in this test intentionally have a non-north orientation
    // so that the compass will be rendered if present.

    @MainActor
    func testEmptyControls() {
        assertView {
            MapView(
                styleURL: demoTilesURL,
                camera: .constant(.center(CLLocationCoordinate2D(), zoom: 4, direction: 45))
            )
            .mapControls {
                // No controls
            }
        }
    }

    @MainActor
    func testLogoOnly() {
        assertView {
            MapView(
                styleURL: demoTilesURL,
                camera: .constant(.center(CLLocationCoordinate2D(), zoom: 4, direction: 45))
            )
            .mapControls {
                LogoView()
            }
        }
    }

    @MainActor
    func testLogoChangePosition() {
        assertView {
            MapView(
                styleURL: demoTilesURL,
                camera: .constant(.center(CLLocationCoordinate2D(), zoom: 4, direction: 45))
            )
            .mapControls {
                LogoView()
                    .position(.topLeft)
            }
        }
    }

    @MainActor
    func testCompassOnly() {
        assertView {
            MapView(
                styleURL: demoTilesURL,
                camera: .constant(.center(CLLocationCoordinate2D(), zoom: 4, direction: 45))
            )
            .mapControls {
                CompassView()
            }
        }
    }

    @MainActor
    func testCompassChangePosition() {
        assertView {
            MapView(
                styleURL: demoTilesURL,
                camera: .constant(.center(CLLocationCoordinate2D(), zoom: 4, direction: 45))
            )
            .mapControls {
                CompassView()
                    .position(.topLeft)
            }
        }
    }

    @MainActor
    func testAttributionOnly() {
        assertView {
            MapView(
                styleURL: demoTilesURL,
                camera: .constant(.center(CLLocationCoordinate2D(), zoom: 4, direction: 45))
            )
            .mapControls {
                AttributionButton()
            }
        }
    }

    @MainActor
    func testAttributionChangePosition() {
        assertView {
            MapView(
                styleURL: demoTilesURL,
                camera: .constant(.center(CLLocationCoordinate2D(), zoom: 4, direction: 45))
            )
            .mapControls {
                AttributionButton()
                    .position(.topLeft)
            }
        }
    }
}
