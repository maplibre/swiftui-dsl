import XCTest
import MapLibre
import MapLibreSwiftDSL
@testable import MapLibreSwiftUI

final class LayerPreviewTests: XCTestCase {

    let demoTilesURL = URL(string: "https://demotiles.maplibre.org/style.json")!

    // A collection of points with various
    // attributes
    let pointSource = ShapeSource(identifier: "points") {
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

    func testRoseTint() {
        assertView {
            MapView(styleURL: demoTilesURL) {
                // Silly example: a background layer on top of everything to create a tint effect
                BackgroundLayer(identifier: "rose-colored-glasses")
                    .backgroundColor(constant: .systemPink.withAlphaComponent(0.3))
                    .renderAboveOthers()
            }
        }
    }
    
    func testSimpleSymbol() {
        assertView {
            MapView(styleURL: demoTilesURL) {
                // Simple symbol layer demonstration with an icon
                SymbolStyleLayer(identifier: "simple-symbols", source: pointSource)
                    .iconImage(constant: UIImage(systemName: "mappin")!)
            }
        }
    }
    
    func testRotatedSymbolConst() {
        assertView {
            MapView(styleURL: demoTilesURL) {
                // Simple symbol layer demonstration with an icon
                SymbolStyleLayer(identifier: "rotated-symbols", source: pointSource)
                    .iconImage(constant: UIImage(systemName: "location.north.circle.fill")!)
                    .iconRotation(constant: 45)
            }
        }
    }
    
    func testRotatedSymboleDynamic() {
        assertView {
            MapView(styleURL: demoTilesURL) {
                // Simple symbol layer demonstration with an icon
                SymbolStyleLayer(identifier: "rotated-symbols", source: pointSource)
                    .iconImage(constant: UIImage(systemName: "location.north.circle.fill")!)
                    .iconRotation(featurePropertyNamed: "heading")
            }
        }
    }
    
    func testCirclesWithSymbols() {
        assertView {
            MapView(styleURL: demoTilesURL) {
                // Simple symbol layer demonstration with an icon
                CircleStyleLayer(identifier: "simple-circles", source: pointSource)
                    .radius(constant: 16)
                    .color(constant: .systemRed)
                    .strokeWidth(constant: 2)
                    .strokeColor(constant: .white)
                    
                SymbolStyleLayer(identifier: "simple-symbols", source: pointSource)
                    .iconImage(constant: UIImage(systemName: "mappin")!.withRenderingMode(.alwaysTemplate))
                    .iconColor(constant: .white)
            }
        }
    }
}
