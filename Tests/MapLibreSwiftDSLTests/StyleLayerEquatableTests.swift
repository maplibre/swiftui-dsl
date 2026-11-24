import MapLibre
import Testing
@testable import MapLibreSwiftDSL

struct StyleLayerEquatableTests {
    private let source = ShapeSource(identifier: "source") {
        MLNPointFeature()
    }

    @Test
    func layersWithTheSamePropertiesAreEqual() {
        func line() -> LineStyleLayer {
            LineStyleLayer(identifier: "line", source: source)
                .lineColor(.red)
                .lineWidth(interpolatedBy: .zoomLevel, curveType: .linear, parameters: nil, stops: NSExpression(
                    forConstantValue: [10: 1, 18: 8]
                ))
                .predicate(NSPredicate(format: "index == 1"))
                .renderBelow(.symbols)
        }

        #expect(line() == line())
    }

    @Test
    func layersWithAnotherStylePropertyAreNotEqual() {
        let line = LineStyleLayer(identifier: "line", source: source)

        #expect(line.lineColor(.red) != line.lineColor(.blue))
        #expect(line.lineWidth(1) != line.lineWidth(2))
    }

    @Test
    func layersWithAnotherCommonPropertyAreNotEqual() {
        let line = LineStyleLayer(identifier: "line", source: source)

        #expect(line != line.visible(false))
        #expect(line != line.minimumZoomLevel(4))
        #expect(line != line.maximumZoomLevel(4))
        #expect(line != line.renderBelow(.symbols))
        #expect(line != line.predicate(NSPredicate(format: "index == 1")))
    }

    @Test
    func layersWithAnotherSourceAreNotEqual() {
        let other = ShapeSource(identifier: "other") {
            MLNPointFeature()
        }

        #expect(LineStyleLayer(identifier: "line", source: source) != LineStyleLayer(identifier: "line", source: other))
    }

    @Test
    func layersWithTheSameSourceObjectAreEqual() {
        let source = MLNSource(identifier: "source")

        #expect(LineStyleLayer(identifier: "line", source: source) == LineStyleLayer(
            identifier: "line",
            source: source
        ))
    }

    @Test
    func layersWithAnotherSourceObjectAreNotEqual() {
        #expect(LineStyleLayer(identifier: "line", source: MLNSource(identifier: "source")) != LineStyleLayer(
            identifier: "line",
            source: MLNSource(identifier: "source")
        ))
    }

    @Test
    func sourceContentIsNotPartOfLayerEquality() {
        let other = ShapeSource(identifier: "source") {
            MLNPolylineFeature()
        }

        #expect(LineStyleLayer(identifier: "line", source: source) == LineStyleLayer(identifier: "line", source: other))
    }

    @Test
    func symbolLayersWithTheSameImageAreEqual() throws {
        let symbol = SymbolStyleLayer(identifier: "symbol", source: source)
        let image = try #require(UIImage(systemName: "mappin"))
        let copy = try #require(UIImage(systemName: "mappin"))

        #expect(symbol.iconImage(image) == symbol.iconImage(image))
        #expect(symbol.iconImage(image) == symbol.iconImage(copy))
    }

    @Test
    func symbolLayersWithAnotherImageAreNotEqual() throws {
        let symbol = SymbolStyleLayer(identifier: "symbol", source: source)
        let image = try #require(UIImage(systemName: "mappin"))
        let other = try #require(UIImage(systemName: "star"))

        #expect(symbol.iconImage(image) != symbol.iconImage(other))
    }

    @Test
    func symbolLayersWithAnotherTextAreNotEqual() {
        let symbol = SymbolStyleLayer(identifier: "symbol", source: source)

        #expect(symbol.text("one") != symbol.text("two"))
    }

    @Test
    func circleFillAndBackgroundLayersCompareTheirProperties() {
        let circle = CircleStyleLayer(identifier: "circle", source: source)
        let fill = FillStyleLayer(identifier: "fill", source: source)
        let background = BackgroundLayer(identifier: "background")

        #expect(circle.radius(1) != circle.radius(2))
        #expect(fill.fillColor(.red) != fill.fillColor(.blue))
        #expect(background.backgroundColor(.red) != background.backgroundColor(.blue))
    }
}
