import CoreLocation
import MapLibreSwiftDSL
import SwiftUI
import Testing
@testable import MapLibreSwiftUI

@MainActor
struct SimpleSymbolTests {
    @Test
    func snapshot() async throws {
        try await assertView {
            MapView(styleURL: demoTilesURL, camera: .constant(.center(CLLocationCoordinate2D(), zoom: 0.0))) {
                SymbolStyleLayer(identifier: "simple-symbols", source: pointSource)
                    .iconImage(previewSymbol(named: "mappin"))
            }
            .ignoresSafeArea(.all)
        }
    }
}
