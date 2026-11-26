import MapLibreSwiftDSL
import SwiftUI
import Testing
@testable import MapLibreSwiftUI

@MainActor
struct RoseTintTests {
    @Test
    func snapshot() async throws {
        try await assertView {
            MapView(styleURL: demoTilesURL, camera: .constant(.center(switzerland, zoom: 6))) {
                BackgroundLayer(identifier: "rose-colored-glasses")
                    .backgroundColor(.systemPink.withAlphaComponent(0.3))
                    .renderAbove(.all)
            }
            .ignoresSafeArea(.all)
        }
    }
}
