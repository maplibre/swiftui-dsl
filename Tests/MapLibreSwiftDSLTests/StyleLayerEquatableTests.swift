import MapLibre
import XCTest
@testable import MapLibreSwiftDSL

final class StyleLayerEquatableTests: XCTestCase {
    private let source = ShapeSource(identifier: "source") {
        MLNPointFeature()
    }

    func testLayersWithTheSamePropertiesAreEqual() {
        func line() -> LineStyleLayer {
            LineStyleLayer(identifier: "line", source: source)
                .lineColor(.red)
                .lineWidth(interpolatedBy: .zoomLevel, curveType: .linear, parameters: nil, stops: NSExpression(
                    forConstantValue: [10: 1, 18: 8]
                ))
                .predicate(NSPredicate(format: "index == 1"))
                .renderBelow(.symbols)
        }

        XCTAssertEqual(line(), line())
    }

    func testLayersWithAnotherStylePropertyAreNotEqual() {
        let line = LineStyleLayer(identifier: "line", source: source)

        XCTAssertNotEqual(line.lineColor(.red), line.lineColor(.blue))
        XCTAssertNotEqual(line.lineWidth(1), line.lineWidth(2))
    }

    func testLayersWithAnotherCommonPropertyAreNotEqual() {
        let line = LineStyleLayer(identifier: "line", source: source)

        XCTAssertNotEqual(line, line.visible(false))
        XCTAssertNotEqual(line, line.minimumZoomLevel(4))
        XCTAssertNotEqual(line, line.maximumZoomLevel(4))
        XCTAssertNotEqual(line, line.renderBelow(.symbols))
        XCTAssertNotEqual(line, line.predicate(NSPredicate(format: "index == 1")))
    }

    func testLayersWithAnotherSourceAreNotEqual() {
        let other = ShapeSource(identifier: "other") {
            MLNPointFeature()
        }

        XCTAssertNotEqual(
            LineStyleLayer(identifier: "line", source: source),
            LineStyleLayer(identifier: "line", source: other)
        )
    }

    func testLayersWithTheSameSourceObjectAreEqual() {
        let source = MLNSource(identifier: "source")

        XCTAssertEqual(
            LineStyleLayer(identifier: "line", source: source),
            LineStyleLayer(identifier: "line", source: source)
        )
    }

    func testLayersWithAnotherSourceObjectAreNotEqual() {
        XCTAssertNotEqual(
            LineStyleLayer(identifier: "line", source: MLNSource(identifier: "source")),
            LineStyleLayer(identifier: "line", source: MLNSource(identifier: "source"))
        )
    }

    func testSourceContentIsNotPartOfLayerEquality() {
        let other = ShapeSource(identifier: "source") {
            MLNPolylineFeature()
        }

        XCTAssertEqual(
            LineStyleLayer(identifier: "line", source: source),
            LineStyleLayer(identifier: "line", source: other)
        )
    }

    func testSymbolLayersWithTheSameImageAreEqual() throws {
        let symbol = SymbolStyleLayer(identifier: "symbol", source: source)
        let image = try XCTUnwrap(UIImage(systemName: "mappin"))
        let copy = try XCTUnwrap(UIImage(systemName: "mappin"))

        XCTAssertEqual(symbol.iconImage(image), symbol.iconImage(image))
        XCTAssertEqual(symbol.iconImage(image), symbol.iconImage(copy))
    }

    func testSymbolLayersWithAnotherImageAreNotEqual() throws {
        let symbol = SymbolStyleLayer(identifier: "symbol", source: source)
        let image = try XCTUnwrap(UIImage(systemName: "mappin"))
        let other = try XCTUnwrap(UIImage(systemName: "star"))

        XCTAssertNotEqual(symbol.iconImage(image), symbol.iconImage(other))
    }

    func testSymbolLayersWithAnotherTextAreNotEqual() {
        let symbol = SymbolStyleLayer(identifier: "symbol", source: source)

        XCTAssertNotEqual(symbol.text("one"), symbol.text("two"))
    }

    func testCircleFillAndBackgroundLayersCompareTheirProperties() {
        let circle = CircleStyleLayer(identifier: "circle", source: source)
        let fill = FillStyleLayer(identifier: "fill", source: source)
        let background = BackgroundLayer(identifier: "background")

        XCTAssertNotEqual(circle.radius(1), circle.radius(2))
        XCTAssertNotEqual(fill.fillColor(.red), fill.fillColor(.blue))
        XCTAssertNotEqual(background.backgroundColor(.red), background.backgroundColor(.blue))
    }
}
