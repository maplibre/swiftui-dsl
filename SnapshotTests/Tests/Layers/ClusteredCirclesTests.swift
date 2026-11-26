import CoreLocation
import MapLibreSwiftDSL
import SwiftUI
import Testing
@testable import MapLibreSwiftUI

@MainActor
struct ClusteredCirclesTests {
    @Test
    func snapshot() async throws {
        try await assertView {
            MapView(styleURL: demoTilesURL, camera: .constant(MapViewCamera.center(
                CLLocationCoordinate2D(latitude: 48.2082, longitude: 16.3719),
                zoom: 5,
                direction: 0
            ))) {
                CircleStyleLayer(identifier: "simple-circles-clusters", source: clustered)
                    .radius(16)
                    .color(.systemRed)
                    .strokeWidth(2)
                    .strokeColor(.white)
                    .predicate(NSPredicate(format: "cluster == YES"))

                SymbolStyleLayer(identifier: "simple-symbols-clusters", source: clustered)
                    .textColor(.white)
                    .text(expression: NSExpression(format: "CAST(point_count, 'NSString')"))
                    .predicate(NSPredicate(format: "cluster == YES"))

                CircleStyleLayer(identifier: "simple-circles-non-clusters", source: clustered)
                    .radius(16)
                    .color(.systemRed)
                    .strokeWidth(2)
                    .strokeColor(.white)
                    .predicate(NSPredicate(format: "cluster != YES"))

                SymbolStyleLayer(identifier: "simple-symbols-non-clusters", source: clustered)
                    .iconImage(previewSymbol(named: "mappin").withRenderingMode(.alwaysTemplate))
                    .iconColor(.white)
                    .predicate(NSPredicate(format: "cluster != YES"))
            }
            .onTapMapGesture(on: ["simple-circles-non-clusters"], onTapChanged: { _, features in
                print("Tapped on \(features.first?.debugDescription ?? "<nil>")")
            })
            .mapClustersExpandOnTapping(clusteredLayers: [ClusterLayer(
                layerIdentifier: "simple-circles-clusters",
                sourceIdentifier: "points"
            )])
            .ignoresSafeArea(.all)
        }
    }
}
