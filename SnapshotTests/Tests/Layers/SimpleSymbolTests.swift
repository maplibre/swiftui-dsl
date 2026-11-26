import CoreLocation
import MapLibreSwiftDSL
import SwiftUI
import Testing
@testable import MapLibreSwiftUI

@MainActor
struct SimpleSymbolTests {
    @Test
    func snapshot() async throws {
        let japan = CLLocationCoordinate2D(latitude: 35.68, longitude: 139.76)
        let source = symbolTestSource(around: japan)
        try await assertView {
            MapView(styleURL: demoTilesURL, camera: .constant(.center(japan, zoom: 12))) {
                SymbolStyleLayer(identifier: "simple-symbols", source: source)
                    .iconImage(previewSymbol(named: "mappin"))
            }
            .ignoresSafeArea(.all)
        }
    }
}
