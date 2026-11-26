import MapLibre
import MapLibreSwiftDSL
import SwiftUI
import Testing
@testable import MapLibreSwiftUI

@Suite(.timeLimit(.minutes(1)))
struct MapViewCoordinatorLineGradientTests {
    /// Users may prepare stops in background tasks; protect the configuration's Sendable contract.
    @Test
    func gradientConfigurationCanCrossActorBoundaries() async {
        let (stops, interpolation) = await Task.detached {
            ([LineStyleLayer.GradientStop(progress: 0, color: .blue),
              LineStyleLayer.GradientStop(progress: 1, color: .red)],
             LineStyleLayer.GradientInterpolation.step)
        }.value
        #expect(stops.map(\.progress) == [0, 1])
        #expect(stops.map(\.color) == [.blue, .red])
        guard case .step = interpolation else {
            Issue.record("Expected the configured interpolation")
            return
        }
    }

    /// Stops beyond the endpoints can influence visible colors; dropping them would diverge from Native.
    @MainActor
    @Test
    func linearGradientPreservesFiniteStopsOutsideLineProgressRange() async throws {
        let expression = try await gradientExpression(stops: [
            .init(progress: -1, color: .blue),
            .init(progress: 2, color: .red),
        ])
        let json = try #require(expression?.mgl_jsonExpressionObject as? NSArray)
        #expect(json[0] as? String == "interpolate")
        // Inspect Native's serialized stop positions independently of the DSL's expression helper.
        let positions = try stride(from: 3, to: json.count, by: 2).map {
            try #require(json[$0] as? NSNumber).doubleValue
        }
        #expect(positions == [-1, 2])
    }

    /// Negative step thresholds can determine the visible color, so retain Native's full set of finite thresholds.
    @MainActor
    @Test
    func steppedGradientPreservesFiniteStopsOutsideLineProgressRange() async throws {
        let expression = try await gradientExpression(stops: [
            .init(progress: -2, color: .green),
            .init(progress: -1, color: .blue),
            .init(progress: 2, color: .red),
        ], interpolation: .step)
        let json = try #require(expression?.mgl_jsonExpressionObject as? NSArray)
        #expect(json[0] as? String == "step")
        // The first color is the step expression's default; the remaining stops retain their positions.
        let positions = try stride(from: 3, to: json.count, by: 2).map {
            try #require(json[$0] as? NSNumber).doubleValue
        }
        #expect(positions == [-1, 2])
    }

    /// Entirely unusable input must leave the gradient unset rather than send non-finite stops to Native.
    @MainActor
    @Test
    func gradientWithOnlyNonfiniteStopsIsUnset() async throws {
        let expression = try await gradientExpression(stops: [
            .init(progress: .nan, color: .blue),
            .init(progress: .infinity, color: .red),
            .init(progress: -.infinity, color: .green),
        ])
        #expect(expression == nil)
    }

    /// Users need predictable colors for unordered or duplicate stops and a uniform color for one usable stop.
    @MainActor
    @Test
    func gradientConfiguration() async throws {
        try await withLoadedMap(line: plainLine) { map, coordinator in
            let styleURL = try #require(map.styleURL)
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
                    plainLine.lineGradient(stops: stops, interpolation: interpolation)
                }
                coordinator.updateLayers(mapView: map)
                let gradient = (map.style?.layer(withIdentifier: "line") as? MLNLineStyleLayer)?.lineGradient
                try expectExpression(gradient, equals: expected)
            }

            // One finite stop produces a uniform color, independently of interpolation mode.
            for interpolation in [LineStyleLayer.GradientInterpolation.linear, .step] {
                coordinator.parent = MapView(styleURL: styleURL) {
                    plainLine.lineGradient(stops: [
                        .init(progress: -.infinity, color: .blue),
                        .init(progress: 0.5, color: .purple),
                    ], interpolation: interpolation)
                }
                coordinator.updateLayers(mapView: map)
                let gradient = (map.style?.layer(withIdentifier: "line") as? MLNLineStyleLayer)?.lineGradient
                try expectExpression(gradient, equals: NSExpression(forConstantValue: UIColor(Color.purple)))
            }
        }
    }

    /// SwiftUI updates must replace stale colors on the existing map and reveal the fallback color after clearing.
    @MainActor
    @Test
    func gradientUpdatesAndClears() async throws {
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
            let styleURL = try #require(map.styleURL)
            let originalMap = map
            let layer = try #require(map.style?.layer(withIdentifier: "line") as? MLNLineStyleLayer)
            try expectExpression(layer.lineGradient, equals: expression)
            #expect(layer.lineWidth == NSExpression(forConstantValue: 4))

            // Updating the DSL content replaces the gradient on the same mounted map.
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
            let updated = try #require(map.style?.layer(withIdentifier: "line") as? MLNLineStyleLayer)
            try expectExpression(updated.lineGradient, equals: stepExpression)

            // Clearing an existing definition must restore its configured fallback line color.
            coordinator.parent = MapView(styleURL: styleURL) { gradientLine.lineGradient(stops: []) }
            coordinator.updateLayers(mapView: map)
            let cleared = try #require(map.style?.layer(withIdentifier: "line") as? MLNLineStyleLayer)
            #expect(cleared.lineGradient == nil)
            #expect(cleared.lineColor == NSExpression(forConstantValue: UIColor.green))
            #expect(coordinator.mapView === originalMap)
        }
    }

    @MainActor
    @Test
    func nonfiniteStopsClearAnExistingGradient() async throws {
        let gradientLine = plainLine.lineGradient(stops: [
            .init(progress: 0, color: .blue),
            .init(progress: 1, color: .red),
        ])
        try await withLoadedMap(line: gradientLine) { map, coordinator in
            let styleURL = try #require(map.styleURL)
            let original = try #require(map.style?.layer(withIdentifier: "line") as? MLNLineStyleLayer)
            try #require(original.lineGradient != nil)

            coordinator.parent = MapView(styleURL: styleURL) {
                gradientLine.lineGradient(stops: [
                    .init(progress: .nan, color: .blue),
                    .init(progress: .infinity, color: .red),
                    .init(progress: -.infinity, color: .green),
                ])
            }
            coordinator.updateLayers(mapView: map)

            let cleared = try #require(map.style?.layer(withIdentifier: "line") as? MLNLineStyleLayer)
            #expect(cleared.lineGradient == nil)
            #expect(cleared.lineColor == NSExpression(forConstantValue: UIColor.green))
        }
    }

    /// Catch stale layer snapshots that would lose a restored gradient when the style reloads in the same update.
    @MainActor
    @Test
    func styleReloadRestoresLatestGradientAfterClearing() async throws {
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
            let styleURL = try #require(map.styleURL)
            let originalMap = map
            // Seed the previous layer snapshot with a cleared gradient to expose stale-snapshot regressions.
            coordinator.parent = MapView(styleURL: styleURL) { gradientLine.lineGradient(stops: []) }
            coordinator.updateLayers(mapView: map)
            #expect((map.style?.layer(withIdentifier: "line") as? MLNLineStyleLayer)?.lineGradient == nil)

            let reloadedStyleURL = styleURL.deletingLastPathComponent().appendingPathComponent("reloaded-style.json")
            try FileManager.default.copyItem(at: styleURL, to: reloadedStyleURL)
            coordinator.parent = MapView(styleURL: reloadedStyleURL) { gradientLine }
            let reloaded = AsyncStream.makeStream(of: Void.self)
            coordinator.onStyleLoaded = { _ in reloaded.continuation.yield(()) }
            // Match the representable's order: change the style, then capture the current layer definitions.
            coordinator.updateStyleSource(.url(reloadedStyleURL), mapView: map)
            coordinator.updateLayers(mapView: map)
            var reloadEvents = reloaded.stream.makeAsyncIterator()
            try #require(await reloadEvents.next() != nil)

            let restored = try #require(map.style?.layer(withIdentifier: "line") as? MLNLineStyleLayer)
            try expectExpression(restored.lineGradient, equals: expression)
            #expect(map.style?.source(withIdentifier: "line") != nil)
            #expect(coordinator.mapView === originalMap)
        }
    }

    private func expectExpression(_ actual: NSExpression?, equals expected: NSExpression) throws {
        let actualJSON = try #require(actual?.mgl_jsonExpressionObject as? NSObject)
        let expectedJSON = try #require(expected.mgl_jsonExpressionObject as? NSObject)
        #expect(actualJSON == expectedJSON)
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
            expression = try #require(map.style?.layer(withIdentifier: "line") as? MLNLineStyleLayer).lineGradient
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
        let loaded = AsyncStream.makeStream(of: Void.self)
        coordinator.onStyleLoaded = { _ in loaded.continuation.yield(()) }
        let map = MLNMapView(frame: CGRect(x: 0, y: 0, width: 320, height: 240), styleURL: styleURL)
        defer {
            coordinator.cancelCameraUpdate()
            map.delegate = nil
        }
        coordinator.mapView = map
        map.delegate = coordinator
        coordinator.updateLayers(mapView: map)
        var loadEvents = loaded.stream.makeAsyncIterator()
        try #require(await loadEvents.next() != nil)
        try await body(map, coordinator)
    }
}
