import CoreLocation
import MapLibreSwiftDSL
import SwiftUI
import Testing
@testable import MapLibreSwiftUI

@MainActor
struct DataDrivenRotationTests {
    @Test
    func snapshot() async throws {
        let kenya = CLLocationCoordinate2D(latitude: -1.286, longitude: 36.817)
        let source = symbolTestSource(around: kenya)
        try await assertView {
            MapView(styleURL: demoTilesURL, camera: .constant(.center(kenya, zoom: 12))) {
                SymbolStyleLayer(identifier: "rotated-symbols", source: source)
                    .iconImage(previewSymbol(named: "location.north.circle.fill"))
                    .iconRotation(featurePropertyNamed: "heading")
            }
            .ignoresSafeArea(.all)
        }
    }
}
