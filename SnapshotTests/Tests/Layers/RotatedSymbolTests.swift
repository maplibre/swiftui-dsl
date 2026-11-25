import CoreLocation
import MapLibreSwiftDSL
import SwiftUI
import Testing
@testable import MapLibreSwiftUI

@MainActor
struct RotatedSymbolTests {
    @Test
    func snapshot() async throws {
        try await assertView {
            MapView(styleURL: demoTilesURL, camera: .constant(.center(CLLocationCoordinate2D(), zoom: 0.0))) {
                SymbolStyleLayer(identifier: "rotated-symbols", source: pointSource)
                    .iconImage(previewSymbol(named: "location.north.circle.fill"))
                    .iconRotation(45)
            }
            .ignoresSafeArea(.all)
        }
    }
}
