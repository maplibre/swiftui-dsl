import MapLibre
import MapLibreSwiftDSL
@testable import MapLibreSwiftUI

/// A map view that has finished loading a style with one symbol layer.
///
/// The tests keep the layers that they compare, because `MLNStyle` holds its layer objects weakly.
@MainActor
final class LoadedMap: NSObject, MLNMapViewDelegate {
    private static let styleJSON = """
    {
        "version": 8,
        "sources": {"style-source": {"type": "geojson", "data": {"type": "Point", "coordinates": [0, 0]}}},
        "layers": [{"id": "style-symbol", "type": "symbol", "source": "style-source"}]
    }
    """

    private let mapView: MLNMapView
    private let styleLayers = StyleLayerCoordinator()
    private var continuation: CheckedContinuation<Void, Never>?

    var style: MLNStyle {
        mapView.style!
    }

    var userLayers: [MLNStyleLayer] {
        style.layers.filter { $0.identifier != "style-symbol" && !$0.identifier.hasPrefix("org.maplibre.") }
    }

    var userLayerIdentifiers: [String] {
        userLayers.map(\.identifier)
    }

    var styleLayerIdentifiers: [String] {
        style.layers.map(\.identifier).filter { !$0.hasPrefix("org.maplibre.") }
    }

    private init(styleURL: URL) {
        mapView = MLNMapView(frame: CGRect(x: 0, y: 0, width: 64, height: 64), styleURL: styleURL)
    }

    static func load() async throws -> LoadedMap {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).json")
        try Data(styleJSON.utf8).write(to: url)

        let map = LoadedMap(styleURL: url)
        await withCheckedContinuation { continuation in
            map.continuation = continuation
            map.mapView.delegate = map
        }
        return map
    }

    func update(_ layers: [StyleLayerDefinition]) {
        styleLayers.update(layers, in: style)
    }

    nonisolated func mapView(_: MLNMapView, didFinishLoading _: MLNStyle) {
        MainActor.assumeIsolated {
            continuation?.resume()
            continuation = nil
        }
    }
}
