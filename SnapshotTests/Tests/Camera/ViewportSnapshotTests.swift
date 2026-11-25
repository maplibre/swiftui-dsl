import MapLibreSwiftUI
import Testing

@MainActor
struct ViewportSnapshotTests {
    @Test
    func cameraAndInsetChange() async throws {
        var action: (@MainActor () async -> Void)?
        var completed = false
        var actual: String?
        var isExpected = false
        try await assertView(waitUntil: { action != nil }, afterSnapshot: {
            let performAction = try #require(action)
            await performAction()
        }, waitUntilAfterAction: { completed }) {
            CameraVsInsetPreview(styleURL: demoTilesURL, onReady: { action = $0 }) { result, passed in
                actual = result
                isExpected = passed
                completed = true
            }
            .ignoresSafeArea(.all)
        }
        #expect(isExpected, "Camera and inset result: \(actual ?? "No result")")
    }

    @Test
    func resizePreservesBoundingBoxFit() async throws {
        var action: (@MainActor () async -> Void)?
        var completed = false
        var actual: String?
        var isExpected = false
        try await assertView(waitUntil: { action != nil }, afterSnapshot: {
            let performAction = try #require(action)
            await performAction()
        }, waitUntilAfterAction: { completed }) {
            ResizeVsFitPreview(styleURL: demoTilesURL, onReady: { action = $0 }) { result, passed in
                actual = result
                isExpected = passed
                completed = true
            }
        }
        #expect(isExpected, "Bounding box fit result: \(actual ?? "No result")")
    }
}
