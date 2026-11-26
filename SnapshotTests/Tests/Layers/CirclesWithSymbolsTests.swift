import CoreLocation
import MapLibreSwiftDSL
import SwiftUI
import Testing
@testable import MapLibreSwiftUI

@MainActor
struct CirclesWithSymbolsTests {
    @Test
    func snapshot() async throws {
        let newZealand = CLLocationCoordinate2D(latitude: -41.286, longitude: 174.776)
        let source = symbolTestSource(around: newZealand)
        try await assertView {
            MapView(styleURL: demoTilesURL, camera: .constant(.center(newZealand, zoom: 12))) {
                CircleStyleLayer(identifier: "simple-circles", source: source)
                    .radius(16)
                    .color(.systemRed)
                    .strokeWidth(2)
                    .strokeColor(.white)

                SymbolStyleLayer(identifier: "simple-symbols", source: source)
                    .iconImage(previewSymbol(named: "mappin").withRenderingMode(.alwaysTemplate))
                    .iconColor(.white)
            }
            .ignoresSafeArea(.all)
        }
    }
}
