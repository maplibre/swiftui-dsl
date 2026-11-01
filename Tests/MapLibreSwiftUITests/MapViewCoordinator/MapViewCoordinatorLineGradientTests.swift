import MapLibre
import MapLibreSwiftDSL
import XCTest
@testable import MapLibreSwiftUI

final class MapViewCoordinatorLineGradientTests: XCTestCase {
    @MainActor
    func testGradientUpdatesClearsAndSurvivesStyleReload() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let styleURL = directory.appendingPathComponent("style.json")
        let reloadedStyleURL = directory.appendingPathComponent("reloaded-style.json")
        let emptyStyle = #"{"version":8,"sources":{},"layers":[]}"#
        try emptyStyle.write(to: styleURL, atomically: true, encoding: .utf8)
        try emptyStyle.write(to: reloadedStyleURL, atomically: true, encoding: .utf8)

        let source = ShapeSource(identifier: "line", options: [.lineDistanceMetrics: true]) {
            MLNPolylineFeature(coordinates: [
                CLLocationCoordinate2D(latitude: 0, longitude: 0),
                CLLocationCoordinate2D(latitude: 1, longitude: 1),
            ])
        }
        let plainLine = LineStyleLayer(identifier: "line", source: source).lineWidth(4).lineColor(.green)
        let stops = NSExpression(forConstantValue: [0: UIColor.blue, 1: UIColor.red])
        let expression = interpolatingExpression(expression: .lineProgress, curveType: .linear,
                                                 parameters: nil, stops: stops)
        let gradientLine = plainLine.lineGradient(interpolatedBy: .lineProgress, curveType: .linear,
                                                  parameters: nil, stops: stops)
        let view = MapView(styleURL: styleURL) { gradientLine }
        let coordinator = view.makeCoordinator()
        let loaded = expectation(description: "Local style loaded")
        coordinator.onStyleLoaded = { _ in loaded.fulfill() }
        let map = MLNMapView(frame: CGRect(x: 0, y: 0, width: 320, height: 240), styleURL: styleURL)
        defer { map.delegate = nil }
        coordinator.mapView = map
        map.delegate = coordinator
        coordinator.updateLayers(mapView: map)
        await fulfillment(of: [loaded], timeout: 10)

        let originalMap = map
        let layer = try XCTUnwrap(map.style?.layer(withIdentifier: "line") as? MLNLineStyleLayer)
        XCTAssertEqual(try XCTUnwrap(layer.lineGradient?.mgl_jsonExpressionObject as? NSArray),
                       try XCTUnwrap(expression.mgl_jsonExpressionObject as? NSArray))
        XCTAssertEqual(layer.lineWidth, NSExpression(forConstantValue: 4))

        let updatedExpression = NSExpression(forConstantValue: UIColor.purple)
        coordinator.parent = MapView(styleURL: styleURL) { plainLine.lineGradient(expression: updatedExpression) }
        coordinator.updateLayers(mapView: map)
        XCTAssertEqual((map.style?.layer(withIdentifier: "line") as? MLNLineStyleLayer)?.lineGradient,
                       updatedExpression)

        coordinator.parent = MapView(styleURL: styleURL) { plainLine }
        coordinator.updateLayers(mapView: map)
        let clearedLayer = try XCTUnwrap(map.style?.layer(withIdentifier: "line") as? MLNLineStyleLayer)
        XCTAssertNil(clearedLayer.lineGradient)
        XCTAssertEqual(clearedLayer.lineColor, NSExpression(forConstantValue: UIColor.green))

        coordinator.parent = MapView(styleURL: reloadedStyleURL) { gradientLine }
        let reloaded = expectation(description: "Replacement local style loaded")
        coordinator.onStyleLoaded = { _ in reloaded.fulfill() }
        coordinator.updateStyleSource(.url(reloadedStyleURL), mapView: map)
        await fulfillment(of: [reloaded], timeout: 10)
        XCTAssertTrue(coordinator.mapView === originalMap)
        let reloadedGradient = (map.style?.layer(withIdentifier: "line") as? MLNLineStyleLayer)?.lineGradient
        XCTAssertEqual(try XCTUnwrap(reloadedGradient?.mgl_jsonExpressionObject as? NSArray),
                       try XCTUnwrap(expression.mgl_jsonExpressionObject as? NSArray))
        XCTAssertNotNil(map.style?.source(withIdentifier: "line"))
    }
}
