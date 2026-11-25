import Testing
@testable import MapLibreSwiftUI

@MainActor
struct LayerTests {
    @Test
    func fill() async throws {
        try await assertView {
            FillStyleLayerPreview()
        }
    }

    @Test
    func polyline() async throws {
        try await assertView {
            PolylineMapView(styleURL: demoTilesURL)
                .ignoresSafeArea(.all)
        }
    }
}
