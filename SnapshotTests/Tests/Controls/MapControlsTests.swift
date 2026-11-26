import CoreLocation
import MapLibreSwiftDSL
import Testing
@testable import MapLibreSwiftUI

@MainActor
struct MapControlsTests {
    // NOTE: The map views in this test intentionally have a non-north orientation
    // so that the compass will be rendered if present.

    @Test
    func emptyControls() async throws {
        try await assertView {
            MapView(
                styleURL: demoTilesURL,
                camera: .constant(.center(CLLocationCoordinate2D(), zoom: 4, direction: 45))
            )
            .mapControls {
                // No controls
            }
        }
    }

    @Test
    func logoOnly() async throws {
        try await assertView {
            MapView(
                styleURL: demoTilesURL,
                camera: .constant(.center(CLLocationCoordinate2D(), zoom: 4, direction: 45))
            )
            .mapControls {
                LogoView()
            }
        }
    }

    @Test
    func logoChangePosition() async throws {
        try await assertView {
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

    @Test
    func compassOnly() async throws {
        try await assertView {
            MapView(
                styleURL: demoTilesURL,
                camera: .constant(.center(CLLocationCoordinate2D(), zoom: 4, direction: 45))
            )
            .mapControls {
                CompassView()
            }
        }
    }

    @Test
    func compassChangePosition() async throws {
        try await assertView {
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

    @Test
    func attributionOnly() async throws {
        try await assertView {
            MapView(
                styleURL: demoTilesURL,
                camera: .constant(.center(CLLocationCoordinate2D(), zoom: 4, direction: 45))
            )
            .mapControls {
                AttributionButton()
            }
        }
    }

    @Test
    func attributionChangePosition() async throws {
        try await assertView {
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
