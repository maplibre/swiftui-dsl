import Testing
@testable import MapLibreSwiftUI

@MainActor
struct CameraPreviewTests {
    @Test
    func cameraZoomAfterDelay() async throws {
        var didFinish = false
        try await assertView(waitUntil: { didFinish }) {
            CameraDirectManipulationPreview(
                styleURL: demoTilesURL,
                targetCameraAfterDelay: .center(switzerland, zoom: 6)
            )
            .onMapIdle { proxy in
                guard !didFinish, abs(proxy.zoomLevel - 6) < 0.01 else { return }
                didFinish = true
            }
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
