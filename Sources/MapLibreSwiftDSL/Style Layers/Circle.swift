import Foundation
import InternalUtils
import MapLibre
import MapLibreSwiftMacros

@MLNStyleProperty<Double>("radius", supportsInterpolation: true)
@MLNStyleProperty<UIColor>("color", supportsInterpolation: false)
@MLNStyleProperty<Double>("strokeWidth", supportsInterpolation: true)
@MLNStyleProperty<UIColor>("strokeColor", supportsInterpolation: false)
@MLNStyleProperty<Double>("circleBlur", supportsInterpolation: true)
@MLNStyleProperty<Double>("circleOpacity", supportsInterpolation: true)
@MLNStyleProperty<Double>("circleStrokeOpacity", supportsInterpolation: true)

public struct CircleStyleLayer: SourceBoundVectorStyleLayerDefinition {
    public let identifier: String
    public let sourceLayerIdentifier: String?
    public var insertionPosition: LayerInsertionPosition = .above(.all)
    public var isVisible: Bool = true
    public var maximumZoomLevel: Float?
    public var minimumZoomLevel: Float?

    public var source: StyleLayerSource
    public var predicate: NSPredicate?

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

    public func makeStyleLayer(style: MLNStyle) -> StyleLayer {
        let styleSource = addSource(to: style)

        return CircleStyleLayerInternal(definition: self, mglSource: styleSource)
    }

    // MARK: - Modifiers
}

private struct CircleStyleLayerInternal: StyleLayer {
    private var definition: CircleStyleLayer
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

    init(definition: CircleStyleLayer, mglSource: MLNSource) {
        self.definition = definition
        self.mglSource = mglSource
    }

    func makeMLNStyleLayer() -> MLNStyleLayer {
        let result = MLNCircleStyleLayer(identifier: identifier, source: mglSource)

        result.sourceLayerIdentifier = definition.sourceLayerIdentifier
        result.circleRadius = definition.radius
        result.circleColor = definition.color

        result.circleStrokeWidth = definition.strokeWidth
        result.circleStrokeColor = definition.strokeColor
        result.circleBlur = definition.circleBlur

        result.circleOpacity = definition.circleOpacity
        result.circleStrokeOpacity = definition.circleStrokeOpacity

        result.predicate = definition.predicate

        return result
    }
}
