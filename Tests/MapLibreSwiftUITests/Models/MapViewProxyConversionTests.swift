import CoreLocation
import MapLibre
import XCTest
@testable import MapLibreSwiftUI

final class MapViewProxyConversionTests: XCTestCase {
    @MainActor func testCoordinateRoundTripInMapAndContainingView() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let styleURL = directory.appendingPathComponent("style.json")
        try #"{"version":8,"sources":{},"layers":[]}"#.write(to: styleURL, atomically: true, encoding: .utf8)
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 800, height: 600))
        let map = MLNMapView(frame: CGRect(x: 70, y: 30, width: 640, height: 480), styleURL: styleURL)
        container.addSubview(map)
        map.automaticallyAdjustsContentInset = false
        map.contentInset = UIEdgeInsets(top: 20, left: 40, bottom: 60, right: 80)
        map.setCenter(CLLocationCoordinate2D(latitude: 48, longitude: 16), zoomLevel: 10, animated: false)
        let proxy = MapViewProxy(mapView: map, lastReasonForChange: nil)
        let coordinate = CLLocationCoordinate2D(latitude: 48.01, longitude: 16.02)

        let point = proxy.convert(coordinate, toPointTo: map)
        let roundTrip = proxy.convert(point)
        XCTAssertEqual(roundTrip.latitude, coordinate.latitude, accuracy: 0.000001)
        XCTAssertEqual(roundTrip.longitude, coordinate.longitude, accuracy: 0.000001)

        let containerPoint = proxy.convert(coordinate, toPointTo: container)
        XCTAssertEqual(containerPoint.x - point.x, 70, accuracy: 0.001)
        XCTAssertEqual(containerPoint.y - point.y, 30, accuracy: 0.001)
        let containerRoundTrip = proxy.convert(containerPoint, toCoordinateFrom: container)
        XCTAssertEqual(containerRoundTrip.latitude, coordinate.latitude, accuracy: 0.000001)
        XCTAssertEqual(containerRoundTrip.longitude, coordinate.longitude, accuracy: 0.000001)
    }
}
