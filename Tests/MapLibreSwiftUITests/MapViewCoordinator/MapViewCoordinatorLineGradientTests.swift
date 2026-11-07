import MapLibre
import MapLibreSwiftDSL
import SwiftUI
import XCTest
@testable import MapLibreSwiftUI

final class MapViewCoordinatorLineGradientTests: XCTestCase {
    func testGradientConfigurationCanCrossActorBoundaries() async {
        let (stops, interpolation) = await Task.detached {
            ([LineStyleLayer.GradientStop(progress: 0, color: .blue),
              LineStyleLayer.GradientStop(progress: 1, color: .red)],
             LineStyleLayer.GradientInterpolation.step)
        }.value
        XCTAssertEqual(stops.map(\.progress), [0, 1])
        XCTAssertEqual(stops.map(\.color), [.blue, .red])
        guard case .step = interpolation else {
            XCTFail("Expected the configured interpolation")
            return
        }
    }

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
        let stops: [Double: UIColor] = [0: .blue, 0.5: .yellow, 1: .red]
        let expression = interpolatingExpression(
            expression: .lineProgress,
            curveType: .linear,
            parameters: nil,
            stops: NSExpression(forConstantValue: stops)
        )
        let gradientLine = plainLine.lineGradient(stops: stops.map {
            .init(progress: $0.key, color: Color(uiColor: $0.value))
        })
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

        let typedStops: [LineStyleLayer.GradientStop] = [
            .init(progress: 1, color: .red),
            .init(progress: 0.5, color: .yellow),
            .init(progress: 0, color: .blue),
            .init(progress: 0.5, color: .purple),
            .init(progress: -1, color: .green),
            .init(progress: 2, color: .green),
            .init(progress: .nan, color: .green),
            .init(progress: .infinity, color: .green),
        ]
        let typedColors = [0: UIColor(Color.blue), 0.5: UIColor(Color.purple), 1: UIColor(Color.red)]
        let typedLinearExpression = interpolatingExpression(
            expression: .lineProgress,
            curveType: .linear,
            parameters: nil,
            stops: NSExpression(forConstantValue: typedColors)
        )
        let typedStepExpression = NSExpression(
            forMLNStepping: .lineProgressVariable,
            from: NSExpression(forConstantValue: UIColor(Color.blue)),
            stops: NSExpression(forConstantValue: [0.5: UIColor(Color.purple), 1: UIColor(Color.red)])
        )
        let typedCases: [(LineStyleLayer.GradientInterpolation, NSExpression)] = [
            (.linear, typedLinearExpression), (.step, typedStepExpression),
        ]
        for (interpolation, expected) in typedCases {
            coordinator.parent = MapView(styleURL: styleURL) {
                plainLine.lineGradient(stops: typedStops, interpolation: interpolation)
            }
            coordinator.updateLayers(mapView: map)
            let gradient = (map.style?.layer(withIdentifier: "line") as? MLNLineStyleLayer)?.lineGradient
            XCTAssertEqual(try XCTUnwrap(gradient?.mgl_jsonExpressionObject as? NSArray),
                           try XCTUnwrap(expected.mgl_jsonExpressionObject as? NSArray))
        }

        coordinator.parent = MapView(styleURL: styleURL) {
            plainLine.lineGradient(stops: [.init(progress: 0.5, color: .purple)])
        }
        coordinator.updateLayers(mapView: map)
        let typedConstant = (map.style?.layer(withIdentifier: "line") as? MLNLineStyleLayer)?.lineGradient
        XCTAssertEqual(try XCTUnwrap(typedConstant?.mgl_jsonExpressionObject as? NSObject),
                       try XCTUnwrap(NSExpression(forConstantValue: UIColor(Color.purple))
                           .mgl_jsonExpressionObject as? NSObject))

        coordinator.parent = MapView(styleURL: styleURL) { plainLine.lineGradient(stops: []) }
        coordinator.updateLayers(mapView: map)
        XCTAssertNil((map.style?.layer(withIdentifier: "line") as? MLNLineStyleLayer)?.lineGradient)

        let stepStops: [Double: UIColor] = [0: .blue, 0.5: .yellow, 0.75: .red]
        let stepExpression = NSExpression(
            forMLNStepping: .lineProgressVariable,
            from: NSExpression(forConstantValue: UIColor.blue),
            stops: NSExpression(forConstantValue: [0.5: UIColor.yellow, 0.75: UIColor.red])
        )
        coordinator.parent = MapView(styleURL: styleURL) {
            plainLine.lineGradient(stops: stepStops.map {
                .init(progress: $0.key, color: Color(uiColor: $0.value))
            }, interpolation: .step)
        }
        coordinator.updateLayers(mapView: map)
        let stepGradient = (map.style?.layer(withIdentifier: "line") as? MLNLineStyleLayer)?.lineGradient
        XCTAssertEqual(try XCTUnwrap(stepGradient?.mgl_jsonExpressionObject as? NSArray),
                       try XCTUnwrap(stepExpression.mgl_jsonExpressionObject as? NSArray))

        coordinator.parent = MapView(styleURL: styleURL) {
            plainLine.lineGradient(stops: [
                .init(progress: -1, color: Color(uiColor: .blue)),
                .init(progress: 0.5, color: Color(uiColor: .purple)),
            ], interpolation: .step)
        }
        coordinator.updateLayers(mapView: map)
        XCTAssertEqual((map.style?.layer(withIdentifier: "line") as? MLNLineStyleLayer)?.lineGradient,
                       NSExpression(forConstantValue: UIColor.purple))

        coordinator.parent = MapView(styleURL: styleURL) { gradientLine.lineGradient(stops: []) }
        coordinator.updateLayers(mapView: map)
        let clearedLayer = try XCTUnwrap(map.style?.layer(withIdentifier: "line") as? MLNLineStyleLayer)
        XCTAssertNil(clearedLayer.lineGradient)
        XCTAssertEqual(clearedLayer.lineColor, NSExpression(forConstantValue: UIColor.green))

        coordinator.parent = MapView(styleURL: reloadedStyleURL) { gradientLine }
        let reloaded = expectation(description: "Replacement local style loaded")
        coordinator.onStyleLoaded = { _ in reloaded.fulfill() }
        coordinator.updateStyleSource(.url(reloadedStyleURL), mapView: map)
        coordinator.updateLayers(mapView: map)
        await fulfillment(of: [reloaded], timeout: 10)
        XCTAssertTrue(coordinator.mapView === originalMap)
        let reloadedGradient = (map.style?.layer(withIdentifier: "line") as? MLNLineStyleLayer)?.lineGradient
        XCTAssertEqual(try XCTUnwrap(reloadedGradient?.mgl_jsonExpressionObject as? NSArray),
                       try XCTUnwrap(expression.mgl_jsonExpressionObject as? NSArray))
        XCTAssertNotNil(map.style?.source(withIdentifier: "line"))
    }
}
