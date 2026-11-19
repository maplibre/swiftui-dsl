import MapLibre
import MapLibreSwiftDSL
import XCTest
@testable import MapLibreSwiftUI

@MainActor
final class StyleLayerCoordinatorTests: XCTestCase {
    private let first = CLLocationCoordinate2D(latitude: 1, longitude: 2)
    private let second = CLLocationCoordinate2D(latitude: 3, longitude: 4)

    private func shapeSource(_ identifier: String = "source", at coordinate: CLLocationCoordinate2D) -> ShapeSource {
        let feature = MLNPointFeature()
        feature.coordinate = coordinate
        return ShapeSource(identifier: identifier) {
            feature
        }
    }

    func testUnchangedLayersAndSourcesStayInTheStyle() async throws {
        let map = try await LoadedMap.load()
        let content = { [self] in [
            CircleStyleLayer(identifier: "first", source: shapeSource(at: first)).color(.red),
            CircleStyleLayer(identifier: "second", source: shapeSource(at: first)).color(.blue),
        ] as [StyleLayerDefinition] }
        map.update(content())
        let layers = map.userLayers
        let source = try XCTUnwrap(map.style.source(withIdentifier: "source"))

        map.update(content())

        XCTAssertTrue(map.userLayers.elementsEqual(layers, by: ===))
        XCTAssertTrue(map.style.source(withIdentifier: "source") === source)
    }

    func testChangedShapeUpdatesTheSourceAndKeepsTheLayers() async throws {
        let map = try await LoadedMap.load()
        map.update([CircleStyleLayer(identifier: "layer", source: shapeSource(at: first))])
        let layers = map.userLayers
        let source = try XCTUnwrap(map.style.source(withIdentifier: "source") as? MLNShapeSource)

        map.update([CircleStyleLayer(identifier: "layer", source: shapeSource(at: second))])

        XCTAssertTrue(map.userLayers.elementsEqual(layers, by: ===))
        XCTAssertTrue(map.style.source(withIdentifier: "source") === source)
        let shape = try XCTUnwrap(source.shape as? MLNShapeCollectionFeature)
        XCTAssertEqual(shape.shapes.first?.coordinate.latitude, second.latitude)
    }

    func testChangedLayerKeepsTheLayersBeforeItAndTheOrder() async throws {
        let map = try await LoadedMap.load()
        let source = shapeSource(at: first)
        func content(_ color: UIColor) -> [StyleLayerDefinition] {
            [
                CircleStyleLayer(identifier: "a", source: source),
                CircleStyleLayer(identifier: "b", source: source).color(color),
                CircleStyleLayer(identifier: "c", source: source),
            ]
        }
        map.update(content(.red))
        let layers = map.userLayers
        let styleSource = try XCTUnwrap(map.style.source(withIdentifier: "source"))

        map.update(content(.blue))

        XCTAssertEqual(map.userLayerIdentifiers, ["a", "b", "c"])
        XCTAssertTrue(map.userLayers[0] === layers[0])
        XCTAssertFalse(map.userLayers[1] === layers[1])
        XCTAssertTrue(map.style.source(withIdentifier: "source") === styleSource)
    }

    func testRemovedLayerRemovesItsSource() async throws {
        let map = try await LoadedMap.load()
        let kept = CircleStyleLayer(identifier: "kept", source: shapeSource("kept-source", at: first))
        map.update([kept, CircleStyleLayer(identifier: "removed", source: shapeSource("removed-source", at: first))])

        map.update([kept])

        XCTAssertEqual(map.userLayerIdentifiers, ["kept"])
        XCTAssertNil(map.style.source(withIdentifier: "removed-source"))
        XCTAssertNotNil(map.style.source(withIdentifier: "kept-source"))
    }

    func testRemovedLayerKeepsASourceThatAnotherLayerUses() async throws {
        let map = try await LoadedMap.load()
        let source = shapeSource(at: first)
        let kept = CircleStyleLayer(identifier: "kept", source: source)
        map.update([kept, CircleStyleLayer(identifier: "removed", source: source)])

        map.update([kept])

        XCTAssertEqual(map.userLayerIdentifiers, ["kept"])
        XCTAssertNotNil(map.style.source(withIdentifier: "source"))
    }

    func testAddedLayerGoesAboveTheOtherLayers() async throws {
        let map = try await LoadedMap.load()
        let kept = CircleStyleLayer(identifier: "kept", source: shapeSource(at: first))
        map.update([kept])
        let layers = map.userLayers

        map.update([kept, CircleStyleLayer(identifier: "added", source: shapeSource("added-source", at: first))])

        XCTAssertEqual(map.userLayerIdentifiers, ["kept", "added"])
        XCTAssertTrue(map.userLayers[0] === layers[0])
    }

    func testLayerInsertedBeforeOthersKeepsTheOrder() async throws {
        let map = try await LoadedMap.load()
        let source = shapeSource(at: first)
        let a = CircleStyleLayer(identifier: "a", source: source)
        let c = CircleStyleLayer(identifier: "c", source: source)
        map.update([a, c])

        map.update([a, CircleStyleLayer(identifier: "b", source: source), c])

        XCTAssertEqual(map.userLayerIdentifiers, ["a", "b", "c"])
    }

    func testSourceThatCannotUpdateIsReplacedWithItsLayers() async throws {
        let map = try await LoadedMap.load()
        let source = CountingSource()
        let content: [StyleLayerDefinition] = [
            CircleStyleLayer(identifier: "first", source: source),
            CircleStyleLayer(identifier: "second", source: source),
        ]
        map.update(content)
        let layers = map.userLayers

        map.update(content)

        XCTAssertEqual(source.counter.count, 2)
        XCTAssertEqual(map.userLayerIdentifiers, ["first", "second"])
        XCTAssertFalse(map.userLayers[0] === layers[0])
    }

    func testLayersThatShareASourceMakeItOnce() async throws {
        let map = try await LoadedMap.load()
        let source = CountingSource()

        map.update([
            CircleStyleLayer(identifier: "first", source: source),
            CircleStyleLayer(identifier: "second", source: source),
        ])

        XCTAssertEqual(source.counter.count, 1)
    }

    func testDuplicateLayerIsIgnored() async throws {
        let map = try await LoadedMap.load()
        let source = shapeSource(at: first)
        let content: [StyleLayerDefinition] = [
            CircleStyleLayer(identifier: "layer", source: source).radius(1),
            CircleStyleLayer(identifier: "layer", source: source).radius(2),
        ]

        map.update(content)
        let layers = map.userLayers
        map.update(content)

        XCTAssertEqual(map.userLayerIdentifiers, ["layer"])
        XCTAssertTrue(map.userLayers.elementsEqual(layers, by: ===))
        let layer = try XCTUnwrap(layers.first as? MLNCircleStyleLayer)
        XCTAssertEqual(layer.circleRadius, NSExpression(forConstantValue: 1))
    }

    func testLayerThatIsNotEquatableIsAddedAgain() async throws {
        let map = try await LoadedMap.load()
        let content: [StyleLayerDefinition] = [CustomLayer(identifier: "custom")]
        map.update(content)
        let layers = map.userLayers

        map.update(content)

        XCTAssertEqual(map.userLayerIdentifiers, ["custom"])
        XCTAssertFalse(map.userLayers[0] === layers[0])
    }

    func testLayerThatLeftTheStyleIsAddedAgain() async throws {
        let map = try await LoadedMap.load()
        let content: [StyleLayerDefinition] = [CircleStyleLayer(identifier: "layer", source: shapeSource(at: first))]
        map.update(content)

        try map.style.removeLayer(XCTUnwrap(map.style.layer(withIdentifier: "layer")))
        map.update(content)

        XCTAssertEqual(map.userLayerIdentifiers, ["layer"])
    }

    func testLayerBelowSymbolsGoesBelowTheSymbolsOfTheStyle() async throws {
        let map = try await LoadedMap.load()
        let source = shapeSource(at: first)
        func content(_ color: UIColor) -> [StyleLayerDefinition] {
            [
                SymbolStyleLayer(identifier: "symbol", source: source).renderBelow(.all),
                CircleStyleLayer(identifier: "circle", source: source).color(color).renderBelow(.symbols),
            ]
        }
        map.update(content(.red))
        let order = map.styleLayerIdentifiers

        map.update(content(.blue))

        XCTAssertEqual(map.styleLayerIdentifiers, order)
        XCTAssertEqual(order, ["symbol", "circle", "style-symbol"])
    }

    func testEachMapKeepsItsOwnLayers() async throws {
        let firstMap = try await LoadedMap.load()
        let secondMap = try await LoadedMap.load()
        let content: [StyleLayerDefinition] = [
            CircleStyleLayer(identifier: "layer", source: shapeSource(at: first)),
        ]
        firstMap.update(content)
        secondMap.update(content)
        let layers = firstMap.userLayers
        let source = try XCTUnwrap(firstMap.style.source(withIdentifier: "source") as? MLNShapeSource)
        let shape = source.shape

        secondMap.update([CircleStyleLayer(identifier: "layer", source: shapeSource(at: second)).color(.red)])
        firstMap.update(content)

        XCTAssertTrue(firstMap.userLayers.elementsEqual(layers, by: ===))
        XCTAssertTrue(firstMap.style.source(withIdentifier: "source") === source)
        XCTAssertTrue(source.shape === shape)
    }
}

private final class Counter {
    var count = 0
}

/// A source without an in-place update.
private struct CountingSource: Source {
    let identifier = "counting-source"
    let counter = Counter()

    func makeMGLSource() -> MLNSource {
        counter.count += 1
        return MLNShapeSource(identifier: identifier, shape: nil, options: nil)
    }
}

private struct CustomLayer: StyleLayer {
    let identifier: String
    var insertionPosition: LayerInsertionPosition = .above(.all)
    var isVisible = true
    var maximumZoomLevel: Float?
    var minimumZoomLevel: Float?

    func makeMLNStyleLayer() -> MLNStyleLayer {
        MLNBackgroundStyleLayer(identifier: identifier)
    }
}
