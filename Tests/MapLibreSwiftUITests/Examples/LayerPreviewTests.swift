import MapLibre
import MapLibreSwiftDSL
import XCTest
@testable import MapLibreSwiftUI

final class LayerPreviewTests: XCTestCase {
    /// A collection of points with various
    /// attributes
    static var pointSource: ShapeSource {
        ShapeSource(identifier: "points") {
            // Uses the DSL to quickly construct point features inline
            MLNPointFeature(coordinate: CLLocationCoordinate2D(latitude: 51.47778, longitude: -0.00139))

            MLNPointFeature(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)) { feature in
                feature.attributes["icon"] = "missing"
                feature.attributes["heading"] = 45
            }

            MLNPointFeature(coordinate: CLLocationCoordinate2D(latitude: 39.02001, longitude: 1.482148)) { feature in
                feature.attributes["icon"] = "club"
                feature.attributes["heading"] = 145
            }
        }
    }

    func testRoseTint() async {
        await assertView {
            MapView(styleURL: demoTilesURL) {
                // Silly example: a background layer on top of everything to create a tint effect
                BackgroundLayer(identifier: "rose-colored-glasses")
                    .backgroundColor(.systemPink.withAlphaComponent(0.3))
                    .renderAbove(.all)
            }
        }
    }

    func testSimpleSymbol() async {
        await assertView {
            MapView(styleURL: demoTilesURL) {
                // Simple symbol layer demonstration with an icon
                SymbolStyleLayer(identifier: "simple-symbols", source: Self.pointSource)
                    .iconImage(UIImage(systemName: "mappin")!)
            }
        }
    }

    func testRotatedSymbolConst() async {
        await assertView {
            MapView(styleURL: demoTilesURL) {
                // Simple symbol layer demonstration with an icon
                SymbolStyleLayer(identifier: "rotated-symbols", source: Self.pointSource)
                    .iconImage(UIImage(systemName: "location.north.circle.fill")!)
                    .iconRotation(45)
            }
        }
    }

    func testRotatedSymboleDynamic() async {
        await assertView {
            MapView(styleURL: demoTilesURL) {
                // Simple symbol layer demonstration with an icon
                SymbolStyleLayer(identifier: "rotated-symbols", source: Self.pointSource)
                    .iconImage(UIImage(systemName: "location.north.circle.fill")!)
                    .iconRotation(featurePropertyNamed: "heading")
            }
        }
    }

    func testCirclesWithSymbols() async {
        await assertView {
            MapView(styleURL: demoTilesURL) {
                // Simple symbol layer demonstration with an icon
                CircleStyleLayer(identifier: "simple-circles", source: Self.pointSource)
                    .radius(16)
                    .color(.systemRed)
                    .strokeWidth(2)
                    .strokeColor(.white)

                SymbolStyleLayer(identifier: "simple-symbols", source: Self.pointSource)
                    .iconImage(UIImage(systemName: "mappin")!.withRenderingMode(.alwaysTemplate))
                    .iconColor(.white)
            }
        }
    }
}
