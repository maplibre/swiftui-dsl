import Foundation
import Mapbox
import InternalUtils

public struct LineStyleLayer: SourceBoundStyleLayerDefinition {
    public let identifier: String
    public var insertionPosition: LayerInsertionPosition = .aboveOthers
    public var isVisible: Bool = true
    public var maximumZoomLevel: Float? = nil
    public var minimumZoomLevel: Float? = nil

    public var source: StyleLayerSource

    // TODO: Other properties and their modifiers
    fileprivate var lineColor: NSExpression = NSExpression(forConstantValue: UIColor.black)
    fileprivate var lineCap: NSExpression? = nil
    fileprivate var lineJoin: NSExpression? = nil
    fileprivate var lineWidth: NSExpression? = nil

    public init(identifier: String, source: Source) {
        self.identifier = identifier
        self.source = .source(source)
    }

    public init(identifier: String, source: MGLSource) {
        self.identifier = identifier
        self.source = .mglSource(source)
    }

    public func makeStyleLayer(style: MGLStyle) -> StyleLayer {
        let styleSource = addSource(to: style)

        return LineStyleLayerInternal(definition: self, mglSource: styleSource)
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

    // TODO: Generalize complex expression variants using macros? Revisit once Swift 5.9 lands
    public func lineWidth(interpolatedBy expression: MGLVariableExpression, curveType: MGLExpressionInterpolationMode, parameters: NSExpression?, stops: NSExpression) -> Self {
        return modified(self) { $0.lineWidth = interpolatingExpression(expression: expression, curveType: curveType, parameters: parameters, stops: stops) }
    }
}

private struct LineStyleLayerInternal: StyleLayer {
    private var definition: LineStyleLayer
    private let mglSource: MGLSource

    public var identifier: String { definition.identifier }
    public var insertionPosition: LayerInsertionPosition {
        get { definition.insertionPosition }
        set { definition.insertionPosition = newValue }
    }
    public var isVisible: Bool {
        get { definition.isVisible }
        set { definition.isVisible = newValue }
    }
    public var maximumZoomLevel: Float? {
        get { definition.maximumZoomLevel }
        set { definition.maximumZoomLevel = newValue }
    }
    public var minimumZoomLevel: Float? {
        get { definition.minimumZoomLevel }
        set { definition.minimumZoomLevel = newValue }
    }

    init(definition: LineStyleLayer, mglSource: MGLSource) {
        self.definition = definition
        self.mglSource = mglSource
    }

    public func makeMGLStyleLayer() -> MGLStyleLayer {
        let result = MGLLineStyleLayer(identifier: identifier, source: mglSource)

        result.lineColor = definition.lineColor
        result.lineCap = definition.lineCap
        result.lineWidth = definition.lineWidth
        result.lineJoin = definition.lineJoin

        return result
    }
}
