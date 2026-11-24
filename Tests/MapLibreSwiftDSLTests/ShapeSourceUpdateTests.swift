import MapLibre
import Testing
@testable import MapLibreSwiftDSL

struct ShapeSourceUpdateTests {
    private let coordinates = [
        CLLocationCoordinate2D(latitude: 1, longitude: 2),
        CLLocationCoordinate2D(latitude: 3, longitude: 4),
        CLLocationCoordinate2D(latitude: 5, longitude: 6),
    ]

    private var otherCoordinates: [CLLocationCoordinate2D] {
        coordinates.dropLast() + [CLLocationCoordinate2D(latitude: 7, longitude: 8)]
    }

    private func point(_ coordinate: CLLocationCoordinate2D) -> MLNPointAnnotation {
        let point = MLNPointAnnotation()
        point.coordinate = coordinate
        return point
    }

    private func pointFeature(
        _ coordinate: CLLocationCoordinate2D,
        attributes: [String: Any] = [:]
    ) -> MLNPointFeature {
        let feature = MLNPointFeature()
        feature.coordinate = coordinate
        feature.attributes = attributes
        return feature
    }

    private func shapes(_ coordinates: [CLLocationCoordinate2D]) -> [(String, MLNShape)] {
        [
            ("point", point(coordinates[2])),
            ("polyline", MLNPolyline(coordinates: coordinates)),
            ("polygon", MLNPolygon(coordinates: coordinates, count: UInt(coordinates.count))),
            ("point collection", MLNPointCollection(coordinates: coordinates, count: UInt(coordinates.count))),
            ("multi polyline", MLNMultiPolyline(polylines: [MLNPolyline(coordinates: coordinates)])),
            (
                "multi polygon",
                MLNMultiPolygon(polygons: [MLNPolygon(coordinates: coordinates, count: UInt(coordinates.count))])
            ),
            ("shape collection", MLNShapeCollection(shapes: [MLNPolyline(coordinates: coordinates)])),
        ]
    }

    private func features(_ coordinates: [CLLocationCoordinate2D]) -> [(String, MLNShape & MLNFeature)] {
        [
            ("point", pointFeature(coordinates[2])),
            ("polyline", MLNPolylineFeature(coordinates: coordinates)),
            ("polygon", MLNPolygonFeature(coordinates: coordinates, count: UInt(coordinates.count))),
            ("point collection", MLNPointCollectionFeature(coordinates: coordinates, count: UInt(coordinates.count))),
            ("multi polyline", MLNMultiPolylineFeature(polylines: [MLNPolylineFeature(coordinates: coordinates)])),
            (
                "multi polygon",
                MLNMultiPolygonFeature(polygons: [MLNPolygonFeature(
                    coordinates: coordinates,
                    count: UInt(coordinates.count)
                )])
            ),
            ("shape collection", MLNShapeCollectionFeature(shapes: [MLNPolylineFeature(coordinates: coordinates)])),
        ]
    }

    @Test
    func shapesWithTheSameCoordinatesAreEqual() {
        for ((name, shape), (_, copy)) in zip(shapes(coordinates), shapes(coordinates)) {
            #expect(ShapeData.shapes([shape]) == .shapes([copy]), "\(name)")
        }
    }

    @Test
    func shapesWithOtherCoordinatesAreNotEqual() {
        for ((name, shape), (_, other)) in zip(shapes(coordinates), shapes(otherCoordinates)) {
            #expect(ShapeData.shapes([shape]) != .shapes([other]), "\(name)")
        }
    }

    @Test
    func featuresWithTheSameCoordinatesAreEqual() {
        for ((name, feature), (_, copy)) in zip(features(coordinates), features(coordinates)) {
            #expect(ShapeData.features([feature]) == .features([copy]), "\(name)")
        }
    }

    @Test
    func featuresWithOtherCoordinatesAreNotEqual() {
        for ((name, feature), (_, other)) in zip(features(coordinates), features(otherCoordinates)) {
            #expect(ShapeData.features([feature]) != .features([other]), "\(name)")
        }
    }

    @Test
    func featuresWithOtherAttributesAreNotEqual() {
        let feature = pointFeature(coordinates[0], attributes: ["index": 1])
        let other = pointFeature(coordinates[0], attributes: ["index": 2])

        #expect(ShapeData.features([feature]) != .features([other]))
    }

    @Test
    func featuresWithOtherIdentifiersAreNotEqual() {
        let feature = pointFeature(coordinates[0])
        feature.identifier = "first"
        let other = pointFeature(coordinates[0])
        other.identifier = "second"

        #expect(ShapeData.features([feature]) != .features([other]))
    }

    @Test
    func updateWithTheSameContentKeepsTheShape() throws {
        let previous = ShapeSource(identifier: "source") { MLNPolyline(coordinates: coordinates) }
        let source = try #require(previous.makeMGLSource() as? MLNShapeSource)
        let shape = source.shape
        let definition = ShapeSource(identifier: "source") { MLNPolyline(coordinates: coordinates) }

        #expect(definition.update(source, from: previous))
        #expect(source.shape === shape)
    }

    @Test
    func updateWithOtherShapesChangesTheShape() throws {
        let previous = ShapeSource(identifier: "source") { MLNPolyline(coordinates: coordinates) }
        let source = try #require(previous.makeMGLSource() as? MLNShapeSource)
        let definition = ShapeSource(identifier: "source") { MLNPolyline(coordinates: otherCoordinates) }

        #expect(definition.update(source, from: previous))

        let expected = try #require(definition.makeMGLSource() as? MLNShapeSource)
        #expect(source.shape == expected.shape)
    }

    @Test
    func updateWithOtherFeaturesChangesTheShape() throws {
        let previous = ShapeSource(identifier: "source") { pointFeature(coordinates[0]) }
        let source = try #require(previous.makeMGLSource() as? MLNShapeSource)
        let definition = ShapeSource(identifier: "source") { pointFeature(coordinates[1]) }

        #expect(definition.update(source, from: previous))

        let expected = try #require(definition.makeMGLSource() as? MLNShapeSource)
        #expect(source.shape == expected.shape)
    }

    @Test
    func updateWithOtherOptionsAsksForANewSource() throws {
        let previous = ShapeSource(identifier: "source", options: [.clustered: true]) {
            MLNPolyline(coordinates: coordinates)
        }
        let source = try #require(previous.makeMGLSource() as? MLNShapeSource)
        let definition = ShapeSource(identifier: "source", options: [.clustered: false]) {
            MLNPolyline(coordinates: coordinates)
        }

        #expect(!(definition.update(source, from: previous)))
    }

    @Test
    func updateWithTheSameOptionsKeepsTheSource() throws {
        let previous = ShapeSource(identifier: "source", options: [.clustered: true]) {
            MLNPolyline(coordinates: coordinates)
        }
        let source = try #require(previous.makeMGLSource() as? MLNShapeSource)
        let definition = ShapeSource(identifier: "source", options: [.clustered: true]) {
            MLNPolyline(coordinates: coordinates)
        }

        #expect(definition.update(source, from: previous))
    }

    @Test
    func aSourceWithoutAnUpdateAsksForANewSource() {
        struct CustomSource: Source {
            let identifier = "source"

            func makeMGLSource() -> MLNSource {
                MLNSource(identifier: identifier)
            }
        }

        #expect(!(CustomSource().update(CustomSource().makeMGLSource(), from: CustomSource())))
    }
}
