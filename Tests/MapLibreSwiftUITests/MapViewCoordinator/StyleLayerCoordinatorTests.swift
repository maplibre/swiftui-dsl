import MapLibre
import MapLibreSwiftDSL
import Testing
@testable import MapLibreSwiftUI

@MainActor
@Suite(.timeLimit(.minutes(1)))
struct StyleLayerCoordinatorTests {
    private let first = CLLocationCoordinate2D(latitude: 1, longitude: 2)
    private let second = CLLocationCoordinate2D(latitude: 3, longitude: 4)

    private func shapeSource(_ identifier: String = "source", at coordinate: CLLocationCoordinate2D) -> ShapeSource {
        let feature = MLNPointFeature()
        feature.coordinate = coordinate
        return ShapeSource(identifier: identifier) {
            feature
        }
    }

    @Test
    func unchangedLayersAndSourcesStayInTheStyle() async throws {
        let map = try await LoadedMap.load()
        let content = { [self] in [
            CircleStyleLayer(identifier: "first", source: shapeSource(at: first)).color(.red),
            CircleStyleLayer(identifier: "second", source: shapeSource(at: first)).color(.blue),
        ] as [StyleLayerDefinition] }
        map.update(content())
        let layers = map.userLayers
        let source = try #require(map.style.source(withIdentifier: "source"))

        map.update(content())

        #expect(map.userLayers.elementsEqual(layers, by: ===))
        #expect(map.style.source(withIdentifier: "source") === source)
    }

    @Test
    func changedShapeUpdatesTheSourceAndKeepsTheLayers() async throws {
        let map = try await LoadedMap.load()
        map.update([CircleStyleLayer(identifier: "layer", source: shapeSource(at: first))])
        let layers = map.userLayers
        let source = try #require(map.style.source(withIdentifier: "source") as? MLNShapeSource)

        map.update([CircleStyleLayer(identifier: "layer", source: shapeSource(at: second))])

        #expect(map.userLayers.elementsEqual(layers, by: ===))
        #expect(map.style.source(withIdentifier: "source") === source)
        let shape = try #require(source.shape as? MLNShapeCollectionFeature)
        #expect(shape.shapes.first?.coordinate.latitude == second.latitude)
    }

    @Test
    func changedLayerKeepsTheLayersBeforeItAndTheOrder() async throws {
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
        let styleSource = try #require(map.style.source(withIdentifier: "source"))

        map.update(content(.blue))

        #expect(map.userLayerIdentifiers == ["a", "b", "c"])
        #expect(map.userLayers[0] === layers[0])
        #expect(!(map.userLayers[1] === layers[1]))
        #expect(map.style.source(withIdentifier: "source") === styleSource)
    }

    @Test
    func removedLayerRemovesItsSource() async throws {
        let map = try await LoadedMap.load()
        let kept = CircleStyleLayer(identifier: "kept", source: shapeSource("kept-source", at: first))
        map.update([kept, CircleStyleLayer(identifier: "removed", source: shapeSource("removed-source", at: first))])

        map.update([kept])

        #expect(map.userLayerIdentifiers == ["kept"])
        #expect(map.style.source(withIdentifier: "removed-source") == nil)
        #expect(map.style.source(withIdentifier: "kept-source") != nil)
    }

    @Test
    func removedLayerKeepsASourceThatAnotherLayerUses() async throws {
        let map = try await LoadedMap.load()
        let source = shapeSource(at: first)
        let kept = CircleStyleLayer(identifier: "kept", source: source)
        map.update([kept, CircleStyleLayer(identifier: "removed", source: source)])

        map.update([kept])

        #expect(map.userLayerIdentifiers == ["kept"])
        #expect(map.style.source(withIdentifier: "source") != nil)
    }

    @Test
    func addedLayerGoesAboveTheOtherLayers() async throws {
        let map = try await LoadedMap.load()
        let kept = CircleStyleLayer(identifier: "kept", source: shapeSource(at: first))
        map.update([kept])
        let layers = map.userLayers

        map.update([kept, CircleStyleLayer(identifier: "added", source: shapeSource("added-source", at: first))])

        #expect(map.userLayerIdentifiers == ["kept", "added"])
        #expect(map.userLayers[0] === layers[0])
    }

    @Test
    func layerInsertedBeforeOthersKeepsTheOrder() async throws {
        let map = try await LoadedMap.load()
        let source = shapeSource(at: first)
        let a = CircleStyleLayer(identifier: "a", source: source)
        let c = CircleStyleLayer(identifier: "c", source: source)
        map.update([a, c])

        map.update([a, CircleStyleLayer(identifier: "b", source: source), c])

        #expect(map.userLayerIdentifiers == ["a", "b", "c"])
    }

    @Test
    func sourceThatCannotUpdateIsReplacedWithItsLayers() async throws {
        let map = try await LoadedMap.load()
        let source = CountingSource()
        let content: [StyleLayerDefinition] = [
            CircleStyleLayer(identifier: "first", source: source),
            CircleStyleLayer(identifier: "second", source: source),
        ]
        map.update(content)
        let layers = map.userLayers

        map.update(content)

        #expect(source.counter.count == 2)
        #expect(map.userLayerIdentifiers == ["first", "second"])
        #expect(!(map.userLayers[0] === layers[0]))
    }

    @Test
    func layersThatShareASourceMakeItOnce() async throws {
        let map = try await LoadedMap.load()
        let source = CountingSource()

        map.update([
            CircleStyleLayer(identifier: "first", source: source),
            CircleStyleLayer(identifier: "second", source: source),
        ])

        #expect(source.counter.count == 1)
    }

    @Test
    func duplicateLayerIsIgnored() async throws {
        let map = try await LoadedMap.load()
        let source = shapeSource(at: first)
        let content: [StyleLayerDefinition] = [
            CircleStyleLayer(identifier: "layer", source: source).radius(1),
            CircleStyleLayer(identifier: "layer", source: source).radius(2),
        ]

        map.update(content)
        let layers = map.userLayers
        map.update(content)

        #expect(map.userLayerIdentifiers == ["layer"])
        #expect(map.userLayers.elementsEqual(layers, by: ===))
        let layer = try #require(layers.first as? MLNCircleStyleLayer)
        #expect(layer.circleRadius == NSExpression(forConstantValue: 1))
    }

    @Test
    func layerThatIsNotEquatableIsAddedAgain() async throws {
        let map = try await LoadedMap.load()
        let content: [StyleLayerDefinition] = [CustomLayer(identifier: "custom")]
        map.update(content)
        let layers = map.userLayers

        map.update(content)

        #expect(map.userLayerIdentifiers == ["custom"])
        #expect(!(map.userLayers[0] === layers[0]))
    }

    @Test
    func layerThatLeftTheStyleIsAddedAgain() async throws {
        let map = try await LoadedMap.load()
        let content: [StyleLayerDefinition] = [CircleStyleLayer(identifier: "layer", source: shapeSource(at: first))]
        map.update(content)

        try map.style.removeLayer(#require(map.style.layer(withIdentifier: "layer")))
        map.update(content)

        #expect(map.userLayerIdentifiers == ["layer"])
    }

    @Test
    func layerBelowSymbolsGoesBelowTheSymbolsOfTheStyle() async throws {
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

        #expect(map.styleLayerIdentifiers == order)
        #expect(order == ["symbol", "circle", "style-symbol"])
    }

    @Test
    func nativeLayerPropertiesFollowDefinitionUpdates() async throws {
        let map = try await LoadedMap.load()
        let source = shapeSource(at: first)
        let configurations: [(visible: Bool, minimumZoom: Float, maximumZoom: Float)] = [
            (false, 3, 12),
            (true, 5, 18),
        ]
        for configuration in configurations {
            map.update([
                CircleStyleLayer(identifier: "layer", source: source)
                    .visible(configuration.visible)
                    .minimumZoomLevel(configuration.minimumZoom)
                    .maximumZoomLevel(configuration.maximumZoom),
            ])
            let layer = try #require(map.style.layer(withIdentifier: "layer"))
            #expect(layer.isVisible == configuration.visible)
            #expect(layer.minimumZoomLevel == configuration.minimumZoom)
            #expect(layer.maximumZoomLevel == configuration.maximumZoom)
        }
    }

    @Test
    func replacedSourceUpdatesLayersThatAlsoUseTheRawSource() async throws {
        let map = try await LoadedMap.load()
        let source = ShapeSource(identifier: "shared", options: [.clustered: false]) { MLNPointFeature() }
        let managed = CircleStyleLayer(identifier: "managed", source: source)
        map.update([managed])
        let original = try #require(map.style.source(withIdentifier: "shared"))
        let raw = CircleStyleLayer(identifier: "raw", source: original)
        map.update([raw, managed])
        let replacement = ShapeSource(identifier: "shared", options: [.clustered: true]) { MLNPointFeature() }

        map.update([raw, CircleStyleLayer(identifier: "managed", source: replacement)])

        #expect(map.userLayerIdentifiers == ["raw", "managed"])
        let updatedSource = try #require(map.style.source(withIdentifier: "shared"))
        withKnownIssue("A retained layer uses the raw source and prevents replacement of the shared DSL source.") {
            #expect(updatedSource !== original)
        }
    }

    @Test
    func eachMapKeepsItsOwnLayers() async throws {
        let firstMap = try await LoadedMap.load()
        let secondMap = try await LoadedMap.load()
        let content: [StyleLayerDefinition] = [
            CircleStyleLayer(identifier: "layer", source: shapeSource(at: first)),
        ]
        firstMap.update(content)
        secondMap.update(content)
        let layers = firstMap.userLayers
        let source = try #require(firstMap.style.source(withIdentifier: "source") as? MLNShapeSource)
        let shape = source.shape

        secondMap.update([CircleStyleLayer(identifier: "layer", source: shapeSource(at: second)).color(.red)])
        firstMap.update(content)

        #expect(firstMap.userLayers.elementsEqual(layers, by: ===))
        #expect(firstMap.style.source(withIdentifier: "source") === source)
        #expect(source.shape === shape)
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
