import Foundation
import InternalUtils
import MapLibre
import MapLibreSwiftMacros

// TODO: Other properties and their modifiers
/// A styled line. For gradients based on line progress, set the shape source's
/// `.lineDistanceMetrics` option to `true`.
@MLNStyleProperty<UIColor>("lineColor", supportsInterpolation: true)
@MLNStyleProperty<Float>("lineOpacity", supportsInterpolation: true)
@MLNRawRepresentableStyleProperty<LineCap>("lineCap")
@MLNRawRepresentableStyleProperty<LineJoin>("lineJoin")
@MLNStyleProperty<[Float]>("lineDashPattern")
@MLNStyleProperty<Float>("lineWidth", supportsInterpolation: true)
@MLNStyleProperty<Float>("lineBlur", supportsInterpolation: true)
public struct LineStyleLayer: SourceBoundVectorStyleLayerDefinition {
    public let identifier: String
    public let sourceLayerIdentifier: String?
    public var insertionPosition: LayerInsertionPosition = .above(.all)
    public var isVisible: Bool = true
    public var maximumZoomLevel: Float?
    public var minimumZoomLevel: Float?

    public var source: StyleLayerSource
    public var predicate: NSPredicate?
    fileprivate var lineGradient: NSExpression?

    public init(identifier: String, source: Source) {
        self.identifier = identifier
        self.source = .source(source)
        sourceLayerIdentifier = nil
    }

    public init(identifier: String, source: MLNSource, sourceLayerIdentifier: String? = nil) {
        self.identifier = identifier
        self.source = .mglSource(source)
        self.sourceLayerIdentifier = sourceLayerIdentifier
    }

    /// How colors change between line-progress stops.
    public enum GradientInterpolation {
        /// Blends neighboring colors.
        case linear
        /// Holds each color until the next stop.
        case step
    }

    /// Applies a color ramp along the line. Enable `.lineDistanceMetrics` on the GeoJSON source.
    ///
    /// Stops are keyed by progress from 0 (start) to 1 (end). Out-of-range stops are ignored.
    /// One valid stop colors the whole line. An empty set clears the gradient.
    public func lineGradient(stops: [Double: UIColor], interpolation: GradientInterpolation = .linear) -> Self {
        var copy = self
        var validStops = stops.filter { (0 ... 1).contains($0.key) }
        guard let first = validStops.min(by: { $0.key < $1.key }) else {
            copy.lineGradient = nil
            return copy
        }
        if validStops.count == 1 {
            copy.lineGradient = NSExpression(forConstantValue: first.value)
            return copy
        }

        switch interpolation {
        case .linear:
            copy.lineGradient = interpolatingExpression(
                expression: .lineProgress,
                curveType: .linear,
                parameters: nil,
                stops: NSExpression(forConstantValue: validStops)
            )
        case .step:
            validStops.removeValue(forKey: first.key)
            copy.lineGradient = NSExpression(
                forMLNStepping: .lineProgressVariable,
                from: NSExpression(forConstantValue: first.value),
                stops: NSExpression(forConstantValue: validStops)
            )
        }
        return copy
    }

    public func makeStyleLayer(style: MLNStyle) -> StyleLayer {
        let styleSource = addSource(to: style)

        return LineStyleLayerInternal(definition: self, mglSource: styleSource)
    }
}

private struct LineStyleLayerInternal: StyleLayer {
    private var definition: LineStyleLayer
    private let mglSource: MLNSource

    var identifier: String {
        definition.identifier
    }

    var insertionPosition: LayerInsertionPosition {
        get { definition.insertionPosition }
        set { definition.insertionPosition = newValue }
    }

    var isVisible: Bool {
        get { definition.isVisible }
        set { definition.isVisible = newValue }
    }

    var maximumZoomLevel: Float? {
        get { definition.maximumZoomLevel }
        set { definition.maximumZoomLevel = newValue }
    }

    var minimumZoomLevel: Float? {
        get { definition.minimumZoomLevel }
        set { definition.minimumZoomLevel = newValue }
    }

    init(definition: LineStyleLayer, mglSource: MLNSource) {
        self.definition = definition
        self.mglSource = mglSource
    }

    func makeMLNStyleLayer() -> MLNStyleLayer {
        let result = MLNLineStyleLayer(identifier: identifier, source: mglSource)

        result.lineColor = definition.lineColor
        result.lineGradient = definition.lineGradient
        result.lineOpacity = definition.lineOpacity
        result.lineCap = definition.lineCap
        result.lineWidth = definition.lineWidth
        result.lineJoin = definition.lineJoin
        result.lineDashPattern = definition.lineDashPattern
        result.lineBlur = definition.lineBlur
        result.predicate = definition.predicate
        result.sourceLayerIdentifier = definition.sourceLayerIdentifier

        return result
    }
}
