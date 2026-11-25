import CoreLocation
import MapLibreSwiftDSL
import SwiftUI
import Testing
@testable import MapLibreSwiftUI

@MainActor
struct RotatedSymbolTests {
    @Test
    func snapshot() async throws {
        let brazil = CLLocationCoordinate2D(latitude: -15.79, longitude: -47.88)
        let source = symbolTestSource(around: brazil)
        try await assertView {
            MapView(styleURL: demoTilesURL, camera: .constant(.center(brazil, zoom: 12))) {
                SymbolStyleLayer(identifier: "rotated-symbols", source: source)
                    .iconImage(previewSymbol(named: "location.north.circle.fill"))
                    .iconRotation(45)
            }
            .ignoresSafeArea(.all)
        }
    }
}
