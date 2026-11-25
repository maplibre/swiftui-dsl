import CoreLocation
import MapLibre
import MapLibreSwiftDSL
import SwiftUI
import Testing
@testable import MapLibreSwiftUI

@MainActor
struct SteppedGradientTests {
    @Test
    func snapshot() async throws {
        try await assertView {
            let source = ShapeSource(identifier: "gradient-line", options: [.lineDistanceMetrics: true]) {
                MLNPolylineFeature(coordinates: [
                    CLLocationCoordinate2D(latitude: 51.47778, longitude: -0.02),
                    CLLocationCoordinate2D(latitude: 51.49, longitude: 0.0),
                    CLLocationCoordinate2D(latitude: 51.47778, longitude: 0.02),
                ])
            }
            MapView(styleURL: demoTilesURL, camera: .constant(.center(
                CLLocationCoordinate2D(latitude: 51.485, longitude: 0.0), zoom: 12
            ))) {
                LineStyleLayer(identifier: "gradient-line", source: source)
                    .lineWidth(8)
                    .lineGradient(stops: [
                        .init(progress: 0, color: .blue),
                        .init(progress: 0.75, color: .red),
                    ], interpolation: .step)
            }
        }
    }
}
