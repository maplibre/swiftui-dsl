import MapLibre
import MapLibreSwiftDSL
import OSLog
#if MapLibreDeveloper
    import Mockable
#endif

private let logger = Logger(subsystem: "MapLibreSwiftUI", category: "StyleLayerCoordinator")

/// Keeps the user layers of a style equal to a list of layer definitions.
#if MapLibreDeveloper
    @Mockable
#endif
protocol StyleLayerCoordinating: AnyObject {
    /// Makes `style` show `layers`.
    ///
    /// - Parameters:
    ///   - layers: The layers that the style must show, from bottom to top.
    ///   - style: The style of the map view, or `nil` if it is not loaded. If it is `nil`, call
    ///     ``addAll(_:to:)`` when the style loads.
    @MainActor func update(_ layers: [StyleLayerDefinition], in style: MLNStyle?)

    /// Adds all `layers` to a style that finished loading.
    @MainActor func addAll(_ layers: [StyleLayerDefinition], to style: MLNStyle)
}

/// Keeps the user layers of a style equal to a list of layer definitions.
///
/// The coordinator keeps each layer and source that did not change, so that MapLibre does not load them again.
@MainActor
final class StyleLayerCoordinator: StyleLayerCoordinating {
    private var layers: [StyleLayerDefinition] = []

    func update(_ layers: [StyleLayerDefinition], in style: MLNStyle?) {
        let layers = removingDuplicates(layers)
        let previousLayers = self.layers
        self.layers = layers

        guard let style else {
            return
        }

        let previousSources = managedSources(of: previousLayers)
        let sources = managedSources(of: layers)
        let replacedSources = updateSources(sources, from: previousSources, in: style)

        let keptLayerCount = countOfKeptLayers(
            from: previousLayers,
            to: layers,
            in: style,
            replacedSources: replacedSources
        )
        for layer in previousLayers.dropFirst(keptLayerCount) {
            style.removeLayer(withIdentifier: layer.identifier)
        }

        // Remove a source only after the layers that use it.
        let removedSources = Set(previousSources.keys).subtracting(sources.keys).union(replacedSources)
        removedSources.forEach(style.removeSource(withIdentifier:))

        addLayers(layers.dropFirst(keptLayerCount), to: style)
    }

    func addAll(_ layers: [StyleLayerDefinition], to style: MLNStyle) {
        let layers = removingDuplicates(layers)
        self.layers = layers
        addLayers(layers[...], to: style)
    }

    /// Returns `layers` without each layer whose identifier an earlier layer uses.
    private func removingDuplicates(_ layers: [StyleLayerDefinition]) -> [StyleLayerDefinition] {
        var identifiers = Set<String>()
        return layers.filter { layer in
            guard identifiers.insert(layer.identifier).inserted else {
                logger.error(
                    "Duplicate layer '\(layer.identifier, privacy: .public)' is ignored. Give each layer a unique identifier."
                )
                return false
            }
            return true
        }
    }

    // MARK: - Sources

    /// Returns the sources that layers specify through the DSL, by identifier.
    ///
    /// For a shared identifier, the first layer's source is used, because the style gets that one.
    private func managedSources(of layers: [StyleLayerDefinition]) -> [String: Source] {
        Dictionary(
            layers.compactMap(\.managedSource).map { ($0.identifier, $0) },
            uniquingKeysWith: { first, _ in first }
        )
    }

    /// Updates in place each source that stays in the style.
    ///
    /// - Returns: The identifiers of the sources that cannot change in place.
    private func updateSources(
        _ sources: [String: Source],
        from previousSources: [String: Source],
        in style: MLNStyle
    ) -> Set<String> {
        var replacedSources = Set<String>()
        for (identifier, source) in sources {
            if let previous = previousSources[identifier],
               let styleSource = style.source(withIdentifier: identifier),
               !source.update(styleSource, from: previous)
            {
                replacedSources.insert(identifier)
            }
        }
        return replacedSources
    }

    // MARK: - Layers

    /// Returns the number of layers at the bottom that the style can keep.
    ///
    /// The count stops at the first changed layer. Each layer above it is added again, so that the layers
    /// keep their order.
    private func countOfKeptLayers(
        from previousLayers: [StyleLayerDefinition],
        to layers: [StyleLayerDefinition],
        in style: MLNStyle,
        replacedSources: Set<String>
    ) -> Int {
        zip(previousLayers, layers).prefix { previous, layer in
            guard layer.isEqual(to: previous), style.layer(withIdentifier: layer.identifier) != nil else {
                return false
            }
            guard let source = layer.managedSource else {
                return true
            }
            return !replacedSources.contains(source.identifier)
        }.count
    }

    private func addLayers(_ layers: ArraySlice<StyleLayerDefinition>, to style: MLNStyle) {
        let firstSymbolLayer = style.firstSymbolLayer(excluding: Set(self.layers.map(\.identifier)))
        for layer in layers {
            style.insertLayer(
                layer.makeMLNStyleLayer(in: style),
                at: layer.insertionPosition,
                firstSymbolLayer: firstSymbolLayer
            )
        }
    }
}
