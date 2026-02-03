import InternalUtils
import MapLibre
import XCTest
@testable import MapLibreSwiftDSL

final class PointFeatureTests: XCTestCase {
    private let primeMeridian = CLLocationCoordinate2D(latitude: 51.47778, longitude: -0.00139)

    func testPointFeatureBuilderCoordsOnly() {
        let feature = MLNPointFeature(coordinate: primeMeridian)

        XCTAssertEqual(feature.coordinate.latitude, primeMeridian.latitude, accuracy: 0.000001)
        XCTAssertEqual(feature.coordinate.longitude, primeMeridian.longitude, accuracy: 0.000001)
        XCTAssertTrue(feature.attributes.isEmpty)
    }

    func testPointFeatureBuilderSetAttributes() {
        let feature = MLNPointFeature(coordinate: primeMeridian) { feature in
            feature.attributes["icon"] = "missing"
        }

        XCTAssertEqual(feature.coordinate.latitude, primeMeridian.latitude, accuracy: 0.000001)
        XCTAssertEqual(feature.coordinate.longitude, primeMeridian.longitude, accuracy: 0.000001)
        XCTAssertEqual(feature.attributes as? [String: AnyHashable], ["icon": "missing"])
    }
}
