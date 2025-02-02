import InternalUtils
import MapLibre

/// Specifies a preference for where the layer should be inserted in the hierarchy.
public enum LayerInsertionPosition: Equatable {
    /// The layer should be inserted above the layer with ID ``layerID``.
    ///
    /// If no such layer exists, the layer will be added above others and an error will be logged.
    case above(layerID: String)
    /// The layer should be inserted below the layer with ID ``layerID``.
    ///
    /// If no such layer exists, the layer will be added above others and an error will be logged.
    case below(layerID: String)
    /// The layer should be inserted above other existing layers.
    case aboveOthers
    /// The layer should be inserted below other existing layers.
    case belowOthers
    /// The layer should be inserted below the first symbol layer (used for labels and iconography).
    ///
    /// If there are no symbol layers in the style, the layer is inserted above other existing layers.
    case belowSymbols
}

/// Internal style enum that wraps a source reference.
///
/// We need to hold on to this so that the coordinator can add the source to the style if necessary.
public enum StyleLayerSource {
    case source(Source)
    case mglSource(MLNSource)
}

public extension StyleLayerSource {
    var identifier: String {
        switch self {
        case let .mglSource(s): s.identifier
        case let .source(s): s.identifier
        }
    }
}

/// A description of layer in a MapLibre style.
///
/// If you think this looks very similar to ``MLNStyleLayer``, you're spot on. While the final result objects
/// built here eventually are such, introducing a separate protocol helps keep things Swifty (in particular,
/// it removes the requirement to use classes; idiomatic DSL builders use structs).
public protocol StyleLayerDefinition {
    /// A string that uniquely identifies the style layer in the style to which it is added.
    var identifier: String { get }

    /// Whether this layer is displayed.
    var isVisible: Bool { get set }

    /// The minimum zoom level at which the layer gets processed and rendered.
    ///
    /// This type is optional since the default values in the C++ code base signifying that the
    /// property has not been explicitly set is an [implementation detail](https://github.com/maplibre/maplibre-native/blob/d92431b404b80b2e111c00a94eae51bbb45920fa/src/mbgl/style/layer_impl.hpp#L52)
    ///  that is not currently documented in the public API.
    var minimumZoomLevel: Float? { get set }

    /// The maximum zoom level at which the layer gets processed and rendered.
    ///
    /// This type is optional since the default values in the C++ code base signifying that the
    /// property has not been explicitly set is an [implementation detail](https://github.com/maplibre/maplibre-native/blob/d92431b404b80b2e111c00a94eae51bbb45920fa/src/mbgl/style/layer_impl.hpp#L53)
    ///  that is not currently documented in the public API.
    var maximumZoomLevel: Float? { get set }

    /// Specifies a preference for where the layer should be inserted in the hierarchy.
    var insertionPosition: LayerInsertionPosition { get set }

    /// Converts a layer definition into a concrete layer which can be added to a style.
    ///
    /// FIXME: Terrible abstraction alert... This currently assumes that any referenced source definitions
    /// have been materialized and added to the style (in the method body if necessary) so that the returned
    /// style layer is able to be turned into a MapLibre style layer and added to the view fairly quickly. This
    /// is a halfway finished abstraction which seems most likely to be fully implemented as an
    /// `addLayerToStyle` or similar method once the implications are all worked out.
    func makeStyleLayer(style: MLNStyle) -> StyleLayer
}

public protocol SourceBoundStyleLayerDefinition: StyleLayerDefinition {
    var source: StyleLayerSource { get set }

    var sourceLayerIdentifier: String? { get }
}

/// Based on MLNVectorStyleLayer
public protocol SourceBoundVectorStyleLayerDefinition: SourceBoundStyleLayerDefinition {
    /**
     The style layer’s predicate.

     Use the style layer’s predicate to include only the features in the source
     layer that satisfy a condition that you define.

     See the *Predicates and Expressions*
     guide for details about the predicate syntax supported by this class:
     https://maplibre.org/maplibre-native/ios/api/predicates-and-expressions.html
     */
    var predicate: NSPredicate? { get set }

    func predicate(_ predicate: NSPredicate) -> Self
}

public extension SourceBoundVectorStyleLayerDefinition {
    func predicate(_ predicate: NSPredicate) -> Self {
        modified(self) { it in
            it.predicate = predicate
        }
    }
}

extension SourceBoundStyleLayerDefinition {
    func addSource(to style: MLNStyle) -> MLNSource {
        let tmpSource: MLNSource

        switch source {
        case let .source(s):
            let source = s.makeMGLSource()
            tmpSource = source
        case let .mglSource(s):
            tmpSource = s
        }

        return addSourceIfNecessary(tmpSource, to: style)
    }
}

public protocol StyleLayer: StyleLayerDefinition {
    /// Builds an ``MLNStyleLayer`` using the layer definition.
    // DISCUSS: Potential leaky abstraction alert! We don't necessarily (TBD?) need this method public, but we do want the protocol conformance. This should be revisited.
    func makeMLNStyleLayer() -> MLNStyleLayer
}

public extension StyleLayer {
    func makeStyleLayer(style _: MLNStyle) -> StyleLayer {
        self
    }
}

public extension StyleLayerDefinition {
    // MARK: - Common modifiers

    func visible(_ value: Bool) -> Self {
        modified(self) { $0.isVisible = value }
    }

    func minimumZoomLevel(_ value: Float) -> Self {
        modified(self) { $0.minimumZoomLevel = value }
    }

    func maximumZoomLevel(_ value: Float) -> Self {
        modified(self) { $0.maximumZoomLevel = value }
    }

    func renderAbove(_ layerID: String) -> Self {
        modified(self) { $0.insertionPosition = .above(layerID: layerID) }
    }

    func renderBelow(_ layerID: String) -> Self {
        modified(self) { $0.insertionPosition = .below(layerID: layerID) }
    }

    func renderAboveOthers() -> Self {
        modified(self) { $0.insertionPosition = .aboveOthers }
    }

    func renderBelowOthers() -> Self {
        modified(self) { $0.insertionPosition = .belowOthers }
    }

    func renderBelowSymbols() -> Self {
        modified(self) { $0.insertionPosition = .belowSymbols }
    }
}
