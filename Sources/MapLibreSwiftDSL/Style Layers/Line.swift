import Foundation
import InternalUtils
import MapLibre
import MapLibreSwiftMacros
import SwiftUI

// TODO: Other properties and their modifiers
/// A styled line.
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
    public enum GradientInterpolation: Sendable {
        /// Blends neighboring colors.
        case linear
        /// Holds each color from its stop until the next stop.
        case step
    }

    /// A color at a position along a gradient line.
    public struct GradientStop: Sendable {
        /// Position in line-progress coordinates, where 0 is the start and 1 is the end.
        /// Finite positions outside this interval are also supported.
        /// Non-finite positions are ignored when applying the gradient.
        public let progress: Double

        /// The color at this stop. Linear interpolation blends neighboring
        /// colors; stepped interpolation holds the color until the next stop.
        public let color: Color

        public init(progress: Double, color: Color) {
            self.progress = progress
            self.color = color
        }
    }

    /// Applies a color gradient along the line.
    ///
    /// Stops define colors in line-progress coordinates, where `0` is the start
    /// and `1` is the end. Like MapLibre Native, finite positions outside `0...1`
    /// are supported and can affect the colors within the visible line.
    /// Stops may be provided in any order. If multiple stops share the same
    /// position, the last supplied stop takes precedence. Stops with non-finite
    /// positions are ignored.
    ///
    /// If only one valid stop remains, its color is applied to the entire line.
    /// If no valid stops remain, the existing gradient is cleared.
    ///
    /// - Important: The GeoJSON source must have `.lineDistanceMetrics` enabled
    ///   for the gradient to work correctly.
    ///
    /// - Note: With stepped interpolation, a stop at `1` has no visible interval.
    ///   Blue at `0` and red at `0.75` color the final quarter red; placing the red
    ///   stop at `1` leaves the line blue. With linear interpolation, a stop at `1`
    ///   defines the final color of the blend.
    ///
    /// - Parameters:
    ///   - stops: The color stops defining the gradient.
    ///   - interpolation: The interpolation mode between stops.
    ///     Defaults to `.linear`.
    ///
    /// - Returns: A copy of this value with the updated line gradient.
    public func lineGradient(stops: [GradientStop], interpolation: GradientInterpolation = .linear) -> Self {
        var copy = self
        var validStops: [Double: UIColor] = [:]
        for stop in stops where stop.progress.isFinite {
            validStops[stop.progress] = UIColor(stop.color)
        }
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
