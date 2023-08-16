import Mapbox

/// Specifies a preference for where the layer should be inserted in the hierarchy.
public enum LayerInsertionPosition {
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
}

/// Internal style enum that wraps a source reference.
///
/// We need to hold on to this so that the coordinator can add the source to the style if necessary.
enum StyleLayerSource {
    case source(Source)
    case mglSource(MGLSource)
}

extension StyleLayerSource {
    var identifier: String {
        switch self {
        case .mglSource(let s): return s.identifier
        case .source(let s): return s.identifier
        }
    }
}

/// A description of layer in a MapLibre style.
///
/// If you think this looks very similar to ``MGLStyleLayer``, you're spot on. While the final result objects
/// built here eventually are such, introducing a separate protocol helps keep things Swifty (in particular,
/// it removes the requirement to use classes; idiomatic DSL builders use structs).
public protocol StyleLayer {
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
    // TODO: Figure out the best way to add layers idiomatically so that they show up beneath label layers, as this is probably desirable in many use cases.
    var insertionPosition: LayerInsertionPosition { get set }

    /// Builds an ``MGLStyleLayer`` using the layer definition.
    // DISCUSS: Potential leaky abstraction alert! We don't necessarily (TBD?) need this method public, but we do want the protocol conformance. This should be revisited.
    func makeMGLStyleLayer() -> MGLStyleLayer
}

protocol SourceBoundStyleLayer: StyleLayer {
    var source: StyleLayerSource { get set }
}


extension StyleLayer {
    // MARK: Common modifiers

    public func visible(_ value: Bool) -> Self {
        return modified(self) { $0.isVisible = value }
    }

    public func minimumZoomLevel(_ value: Float) -> Self {
        return modified(self) { $0.minimumZoomLevel = value }
    }

    public func maximumZoomLevel(_ value: Float) -> Self {
        return modified(self) { $0.maximumZoomLevel = value }
    }

    public func renderAbove(_ layerID: String) -> Self {
        return modified(self) { $0.insertionPosition = .above(layerID: layerID) }
    }

    public func renderBelow(_ layerID: String) -> Self {
        return modified(self) { $0.insertionPosition = .below(layerID: layerID) }
    }

    public func renderAboveOthers() -> Self {
        return modified(self) { $0.insertionPosition = .aboveOthers }
    }

    public func renderBelowOthers() -> Self {
        return modified(self) { $0.insertionPosition = .belowOthers }
    }
}

public struct BackgroundLayer: StyleLayer {
    public let identifier: String
    public var insertionPosition: LayerInsertionPosition = .belowOthers
    public var isVisible: Bool = true
    public var maximumZoomLevel: Float? = nil
    public var minimumZoomLevel: Float? = nil

    // TODO: Other properties and their modifiers
    private var backgroundColor: NSExpression = NSExpression(forConstantValue: UIColor.black)
    private var backgroundOpacity: NSExpression = NSExpression(forConstantValue: 1.0)


    init(identifier: String) {
        self.identifier = identifier
    }

    // MARK: Modifiers

    public func backgroundColor(_ color: UIColor) -> Self {
        return modified(self) { $0.backgroundColor = NSExpression(forConstantValue: color) }
    }

    public func backgroundOpacity(_ opacity: Float) -> Self {
        return modified(self) { $0.backgroundOpacity = NSExpression(forConstantValue: opacity) }
    }

    // MARK: Internal helpers

    public func makeMGLStyleLayer() -> MGLStyleLayer {
        let result = MGLBackgroundStyleLayer(identifier: identifier)

        result.backgroundColor = backgroundColor
        result.backgroundOpacity = backgroundOpacity

        return result
    }
}

public struct LineStyleLayer: SourceBoundStyleLayer {
    public let identifier: String
    public var insertionPosition: LayerInsertionPosition = .aboveOthers
    public var isVisible: Bool = true
    public var maximumZoomLevel: Float? = nil
    public var minimumZoomLevel: Float? = nil

    var source: StyleLayerSource

    // TODO: Other properties and their modifiers
    private var lineColor: NSExpression = NSExpression(forConstantValue: UIColor.black)
    private var lineCap: NSExpression? = nil
    private var lineJoin: NSExpression? = nil
    private var lineWidth: NSExpression? = nil

    init(identifier: String, source: Source) {
        self.identifier = identifier
        self.source = .source(source)
    }

    init(identifier: String, source: MGLSource) {
        self.identifier = identifier
        self.source = .mglSource(source)
    }


    // MARK: Modifiers

    public func lineColor(constant color: UIColor) -> Self {
        return modified(self) { $0.lineColor = NSExpression(forConstantValue: color) }
    }

    public func lineCap(constant cap: LineCap) -> Self {
        return modified(self) { $0.lineCap = NSExpression(forConstantValue: cap.mglLineCapValue.rawValue) }
    }

    public func lineJoin(constant cap: LineJoin) -> Self {
        return modified(self) { $0.lineJoin = NSExpression(forConstantValue: cap.mglLineJoinValue.rawValue) }
    }

    public func lineWidth(constant constantWidth: Float) -> Self {
        return modified(self) { $0.lineWidth = NSExpression(forConstantValue: constantWidth) }
    }

    // MARK: Internal helpers

    public func makeMGLStyleLayer() -> MGLStyleLayer {
        let mglSource: MGLSource
        switch source {
        case .source(_):
            fatalError("Programming error: Callers must ensure that the source has been generated exactly once, added to the style, and the original type updated with a reference to the source.")
        case .mglSource(let s):
            mglSource = s
        }

        let result = MGLLineStyleLayer(identifier: identifier, source: mglSource)

        result.lineColor = lineColor
        result.lineCap = lineCap
        result.lineWidth = lineWidth
        result.lineJoin = lineJoin

        return result
    }
}
