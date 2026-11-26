import Testing
@testable import MapLibreSwiftUI

@MainActor
struct CameraTests {
    @Test
    func centeredCamera() async throws {
        try await assertView {
            MapView(
                styleURL: demoTilesURL,
                camera: .constant(.center(switzerland, zoom: 6))
            )
            .ignoresSafeArea(.all)
        }
    }

    @Test
    func showcasePolyline() async throws {
        try await assertView {
            CameraShowcasePolylinePreview(styleURL: demoTilesURL)
                .ignoresSafeArea(.all)
        }
    }
}
