import MapLibre
import MapLibreSwiftDSL
import SwiftUI
import XCTest
@testable import MapLibreSwiftUI

final class MapViewCoordinatorLineGradientTests: XCTestCase {
    /// Users may prepare stops in background tasks; protect the configuration's Sendable contract.
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

    /// Stops beyond the endpoints can influence visible colors; dropping them would diverge from Native.
    @MainActor
    func testLinearGradientPreservesFiniteStopsOutsideLineProgressRange() async throws {
        let expression = try await gradientExpression(stops: [
            .init(progress: -1, color: .blue),
            .init(progress: 2, color: .red),
        ])
        let json = try XCTUnwrap(expression?.mgl_jsonExpressionObject as? NSArray)
        XCTAssertEqual(json[0] as? String, "interpolate")
        // Inspect Native's serialized stop positions independently of the DSL's expression helper.
        let positions = try stride(from: 3, to: json.count, by: 2).map {
            try XCTUnwrap(json[$0] as? NSNumber).doubleValue
        }
        XCTAssertEqual(positions, [-1, 2])
    }

    /// Negative step thresholds can determine the visible color, so retain Native's full set of finite thresholds.
    @MainActor
    func testSteppedGradientPreservesFiniteStopsOutsideLineProgressRange() async throws {
        let expression = try await gradientExpression(stops: [
            .init(progress: -2, color: .green),
            .init(progress: -1, color: .blue),
            .init(progress: 2, color: .red),
        ], interpolation: .step)
        let json = try XCTUnwrap(expression?.mgl_jsonExpressionObject as? NSArray)
        XCTAssertEqual(json[0] as? String, "step")
        // The first color is the step expression's default; the remaining stops retain their positions.
        let positions = try stride(from: 3, to: json.count, by: 2).map {
            try XCTUnwrap(json[$0] as? NSNumber).doubleValue
        }
        XCTAssertEqual(positions, [-1, 2])
    }

    /// Entirely unusable input must leave the gradient unset rather than send non-finite stops to Native.
    @MainActor
    func testGradientWithOnlyNonfiniteStopsIsUnset() async throws {
        let expression = try await gradientExpression(stops: [
            .init(progress: .nan, color: .blue),
            .init(progress: .infinity, color: .red),
            .init(progress: -.infinity, color: .green),
        ])
        XCTAssertNil(expression)
    }

    /// Users need predictable colors for unordered or duplicate stops and a uniform color for one usable stop.
    @MainActor
    func testGradientConfiguration() async throws {
        try await withLoadedMap(line: plainLine) { map, coordinator in
            let styleURL = try XCTUnwrap(map.styleURL)
            // Both modes normalize unordered/duplicate stops and ignore non-finite positions.
            let stops: [LineStyleLayer.GradientStop] = [
                .init(progress: 1, color: .red),
                .init(progress: 0.5, color: .yellow),
                .init(progress: 0, color: .blue),
                .init(progress: 0.5, color: .purple),
                .init(progress: -1, color: .green),
                .init(progress: 2, color: .green),
                .init(progress: .nan, color: .green),
                .init(progress: .infinity, color: .green),
            ]
            let colors = [-1: UIColor(Color.green), 0: UIColor(Color.blue), 0.5: UIColor(Color.purple),
                          1: UIColor(Color.red), 2: UIColor(Color.green)]
            let linear = interpolatingExpression(
                expression: .lineProgress,
                curveType: .linear,
                parameters: nil,
                stops: NSExpression(forConstantValue: colors)
            )
            let step = NSExpression(
                forMLNStepping: .lineProgressVariable,
                from: NSExpression(forConstantValue: UIColor(Color.green)),
                stops: NSExpression(forConstantValue: [0: UIColor(Color.blue), 0.5: UIColor(Color.purple),
                                                       1: UIColor(Color.red), 2: UIColor(Color.green)])
            )
            let cases: [(LineStyleLayer.GradientInterpolation, NSExpression)] = [(.linear, linear), (.step, step)]
            for (interpolation, expected) in cases {
                coordinator.parent = MapView(styleURL: styleURL) {
                    self.plainLine.lineGradient(stops: stops, interpolation: interpolation)
                }
                coordinator.updateLayers(mapView: map)
                let gradient = (map.style?.layer(withIdentifier: "line") as? MLNLineStyleLayer)?.lineGradient
                XCTAssertEqual(try XCTUnwrap(gradient?.mgl_jsonExpressionObject as? NSArray),
                               try XCTUnwrap(expected.mgl_jsonExpressionObject as? NSArray))
            }

            // One finite stop produces a uniform color, independently of interpolation mode.
            for interpolation in [LineStyleLayer.GradientInterpolation.linear, .step] {
                coordinator.parent = MapView(styleURL: styleURL) {
                    self.plainLine.lineGradient(stops: [
                        .init(progress: -.infinity, color: .blue),
                        .init(progress: 0.5, color: .purple),
                    ], interpolation: interpolation)
                }
                coordinator.updateLayers(mapView: map)
                let gradient = (map.style?.layer(withIdentifier: "line") as? MLNLineStyleLayer)?.lineGradient
                XCTAssertEqual(try XCTUnwrap(gradient?.mgl_jsonExpressionObject as? NSObject),
                               try XCTUnwrap(NSExpression(forConstantValue: UIColor(Color.purple))
                                   .mgl_jsonExpressionObject as? NSObject))
            }
        }
    }

    /// SwiftUI updates must replace stale colors on the existing map and reveal the fallback color after clearing.
    @MainActor
    func testGradientUpdatesAndClears() async throws {
        let stops: [Double: UIColor] = [0: .blue, 0.5: .yellow, 1: .red]
        let gradientLine = plainLine.lineGradient(stops: stops.map {
            .init(progress: $0.key, color: Color(uiColor: $0.value))
        })
        let expression = interpolatingExpression(
            expression: .lineProgress,
            curveType: .linear,
            parameters: nil,
            stops: NSExpression(forConstantValue: stops)
        )
        try await withLoadedMap(line: gradientLine) { map, coordinator in
            let styleURL = try XCTUnwrap(map.styleURL)
            let originalMap = map
            let layer = try XCTUnwrap(map.style?.layer(withIdentifier: "line") as? MLNLineStyleLayer)
            XCTAssertEqual(try XCTUnwrap(layer.lineGradient?.mgl_jsonExpressionObject as? NSArray),
                           try XCTUnwrap(expression.mgl_jsonExpressionObject as? NSArray))
            XCTAssertEqual(layer.lineWidth, NSExpression(forConstantValue: 4))

            // Updating the DSL content replaces the gradient on the same mounted map.
            let stepStops: [Double: UIColor] = [0: .blue, 0.5: .yellow, 0.75: .red]
            let stepExpression = NSExpression(
                forMLNStepping: .lineProgressVariable,
                from: NSExpression(forConstantValue: UIColor.blue),
                stops: NSExpression(forConstantValue: [0.5: UIColor.yellow, 0.75: UIColor.red])
            )
            coordinator.parent = MapView(styleURL: styleURL) {
                self.plainLine.lineGradient(stops: stepStops.map {
                    .init(progress: $0.key, color: Color(uiColor: $0.value))
                }, interpolation: .step)
            }
            coordinator.updateLayers(mapView: map)
            let updated = try XCTUnwrap(map.style?.layer(withIdentifier: "line") as? MLNLineStyleLayer)
            XCTAssertEqual(try XCTUnwrap(updated.lineGradient?.mgl_jsonExpressionObject as? NSArray),
                           try XCTUnwrap(stepExpression.mgl_jsonExpressionObject as? NSArray))

            // Clearing an existing definition must restore its configured fallback line color.
            coordinator.parent = MapView(styleURL: styleURL) { gradientLine.lineGradient(stops: []) }
            coordinator.updateLayers(mapView: map)
            let cleared = try XCTUnwrap(map.style?.layer(withIdentifier: "line") as? MLNLineStyleLayer)
            XCTAssertNil(cleared.lineGradient)
            XCTAssertEqual(cleared.lineColor, NSExpression(forConstantValue: UIColor.green))
            XCTAssertTrue(coordinator.mapView === originalMap)
        }
    }

    /// Catch stale layer snapshots that would lose a restored gradient when the style reloads in the same update.
    @MainActor
    func testStyleReloadRestoresLatestGradientAfterClearing() async throws {
        let stops: [Double: UIColor] = [0: .blue, 0.5: .yellow, 1: .red]
        let gradientLine = plainLine.lineGradient(stops: stops.map {
            .init(progress: $0.key, color: Color(uiColor: $0.value))
        })
        let expression = interpolatingExpression(
            expression: .lineProgress,
            curveType: .linear,
            parameters: nil,
            stops: NSExpression(forConstantValue: stops)
        )
        try await withLoadedMap(line: gradientLine) { map, coordinator in
            let styleURL = try XCTUnwrap(map.styleURL)
            let originalMap = map
            // Seed the previous layer snapshot with a cleared gradient to expose stale-snapshot regressions.
            coordinator.parent = MapView(styleURL: styleURL) { gradientLine.lineGradient(stops: []) }
            coordinator.updateLayers(mapView: map)
            XCTAssertNil((map.style?.layer(withIdentifier: "line") as? MLNLineStyleLayer)?.lineGradient)

            let reloadedStyleURL = styleURL.deletingLastPathComponent().appendingPathComponent("reloaded-style.json")
            try FileManager.default.copyItem(at: styleURL, to: reloadedStyleURL)
            coordinator.parent = MapView(styleURL: reloadedStyleURL) { gradientLine }
            let reloaded = self.expectation(description: "Replacement local style loaded")
            coordinator.onStyleLoaded = { _ in reloaded.fulfill() }
            // Match the representable's order: change the style, then capture the current layer definitions.
            coordinator.updateStyleSource(.url(reloadedStyleURL), mapView: map)
            coordinator.updateLayers(mapView: map)
            await self.fulfillment(of: [reloaded], timeout: 10)

            let restored = try XCTUnwrap(map.style?.layer(withIdentifier: "line") as? MLNLineStyleLayer)
            XCTAssertEqual(try XCTUnwrap(restored.lineGradient?.mgl_jsonExpressionObject as? NSArray),
                           try XCTUnwrap(expression.mgl_jsonExpressionObject as? NSArray))
            XCTAssertNotNil(map.style?.source(withIdentifier: "line"))
            XCTAssertTrue(coordinator.mapView === originalMap)
        }
    }

    @MainActor
    private var plainLine: LineStyleLayer {
        let source = ShapeSource(identifier: "line", options: [.lineDistanceMetrics: true]) {
            MLNPolylineFeature(coordinates: [
                CLLocationCoordinate2D(latitude: 0, longitude: 0),
                CLLocationCoordinate2D(latitude: 1, longitude: 1),
            ])
        }
        return LineStyleLayer(identifier: "line", source: source).lineWidth(4).lineColor(.green)
    }

    @MainActor
    private func gradientExpression(
        stops: [LineStyleLayer.GradientStop],
        interpolation: LineStyleLayer.GradientInterpolation = .linear
    ) async throws -> NSExpression? {
        var expression: NSExpression?
        try await withLoadedMap(line: plainLine.lineGradient(stops: stops, interpolation: interpolation)) { map, _ in
            expression = try XCTUnwrap(map.style?.layer(withIdentifier: "line") as? MLNLineStyleLayer).lineGradient
        }
        return expression
    }

    @MainActor
    private func withLoadedMap(
        line: LineStyleLayer,
        body: @MainActor (MLNMapView, MapViewCoordinator<MLNMapViewController>) async throws -> Void
    ) async throws {
        // A local style exercises Native's actual setter without network or rendered snapshot dependencies.
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let styleURL = directory.appendingPathComponent("style.json")
        try #"{"version":8,"sources":{},"layers":[]}"#.write(to: styleURL, atomically: true, encoding: .utf8)
        let view = MapView(styleURL: styleURL) { line }
        let coordinator = view.makeCoordinator()
        let loaded = expectation(description: "Local gradient style loaded")
        coordinator.onStyleLoaded = { _ in loaded.fulfill() }
        let map = MLNMapView(frame: CGRect(x: 0, y: 0, width: 320, height: 240), styleURL: styleURL)
        defer { map.delegate = nil }
        coordinator.mapView = map
        map.delegate = coordinator
        coordinator.updateLayers(mapView: map)
        await fulfillment(of: [loaded], timeout: 10)
        try await body(map, coordinator)
    }
}
