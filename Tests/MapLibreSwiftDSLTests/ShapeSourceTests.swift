import InternalUtils
import MapLibre
import XCTest
@testable import MapLibreSwiftDSL

final class ShapeSourceTests: XCTestCase {
    func testShapeSourcePolylineShapeBuilder() {
        // Ideally in a style context, these could be tested at compile time to
        // ensure there are no duplicate IDs.
        let shapeSource = ShapeSource(identifier: "foo") {
            MLNPolyline(coordinates: samplePedestrianWaypoints)
        }

        XCTAssertEqual(shapeSource.identifier, "foo")

        switch shapeSource.data {
        case let .shapes(shapes):
            XCTAssertEqual(shapes.count, 1)
        default:
            XCTFail("Expected a shape source")
        }
    }

    func testShapeSourcePolylineFeatureBuilder() {
        let shapeSource = ShapeSource(identifier: "foo") {
            MLNPolylineFeature(coordinates: samplePedestrianWaypoints)
        }

        XCTAssertEqual(shapeSource.identifier, "foo")

        switch shapeSource.data {
        case let .features(features):
            XCTAssertEqual(features.count, 1)
        default:
            XCTFail("Expected a feature source")
        }
    }

    func testForInAndCombinationFeatureBuilder() {
        // ShapeSource now accepts 'for in' building, arrays, and combinations of them
        let shapeSource = ShapeSource(identifier: "foo") {
            for coordinates in samplePedestrianWaypoints {
                MLNPointFeature(coordinate: coordinates)
            }
            MLNPointFeature(coordinate: CLLocationCoordinate2D(latitude: 48.2082, longitude: 16.3719))
        }

        XCTAssertEqual(shapeSource.identifier, "foo")

        switch shapeSource.data {
        case let .features(features):
            XCTAssertEqual(features.count, 48)
        default:
            XCTFail("Expected a feature source")
        }
    }
}
