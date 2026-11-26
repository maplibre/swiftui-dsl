import MapLibre
import MapLibreSwiftDSL
import OSLog

private let logger = Logger(subsystem: "MapLibreSwiftUI", category: "MLNStyle")

extension MLNStyle {
    func removeLayer(withIdentifier identifier: String) {
        if let layer = layer(withIdentifier: identifier) {
            removeLayer(layer)
        }
    }

    func removeSource(withIdentifier identifier: String) {
        if let source = source(withIdentifier: identifier) {
            removeSource(source)
        }
    }

    /// Returns the bottom symbol layer whose identifier is not in `identifiers`.
    func firstSymbolLayer(excluding identifiers: Set<String>) -> MLNStyleLayer? {
        layers.first { $0 is MLNSymbolStyleLayer && !identifiers.contains($0.identifier) }
    }

    /// Inserts `layer` at `position`.
    ///
    /// If the position refers to a layer that is not in the style, `layer` goes on top.
    ///
    /// - Parameters:
    ///   - layer: The layer to insert.
    ///   - position: The position of the layer.
    ///   - firstSymbolLayer: The layer that ``LayerReferenceBelow/symbols`` refers to.
    func insertLayer(
        _ layer: MLNStyleLayer,
        at position: LayerInsertionPosition,
        firstSymbolLayer: MLNStyleLayer?
    ) {
        switch position {
        case .above(.all):
            addLayer(layer)
        case .below(.all):
            insertLayer(layer, at: 0)
        case let .above(.layer(layerId: identifier)):
            if let reference = referenceLayer(identifier, for: layer) {
                insertLayer(layer, above: reference)
            } else {
                addLayer(layer)
            }
        case let .below(.layer(layerId: identifier)):
            if let reference = referenceLayer(identifier, for: layer) {
                insertLayer(layer, below: reference)
            } else {
                addLayer(layer)
            }
        case .below(.symbols):
            if let firstSymbolLayer {
                insertLayer(layer, below: firstSymbolLayer)
            } else {
                addLayer(layer)
            }
        }
    }

    private func referenceLayer(_ identifier: String, for layer: MLNStyleLayer) -> MLNStyleLayer? {
        guard let reference = self.layer(withIdentifier: identifier) else {
            logger.error(
                "Layer '\(identifier, privacy: .public)' is not in the style. Layer '\(layer.identifier, privacy: .public)' is added on top."
            )
            return nil
        }
        return reference
    }
}
