import Foundation
import InternalUtils
import MapLibre
import MapLibreSwiftMacros

@MLNStyleProperty<Double>("radius", supportsInterpolation: true)
@MLNStyleProperty<UIColor>("color", supportsInterpolation: false)
@MLNStyleProperty<Double>("strokeWidth", supportsInterpolation: true)
@MLNStyleProperty<UIColor>("strokeColor", supportsInterpolation: false)
public struct CircleStyleLayer: SourceBoundStyleLayerDefinition {
    public let identifier: String
    public var insertionPosition: LayerInsertionPosition = .aboveOthers
    public var isVisible: Bool = true
    public var maximumZoomLevel: Float? = nil
    public var minimumZoomLevel: Float? = nil
    
    public var source: StyleLayerSource
    
    public init(identifier: String, source: Source) {
        self.identifier = identifier
        self.source = .source(source)
    }
    
    public init(identifier: String, source: MLNSource) {
        self.identifier = identifier
        self.source = .mglSource(source)
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
    
    init(definition: CircleStyleLayer, mglSource: MLNSource) {
        self.definition = definition
        self.mglSource = mglSource
    }
    
    public func makeMLNStyleLayer() -> MLNStyleLayer {
        let result = MLNCircleStyleLayer(identifier: identifier, source: mglSource)
        
        result.circleRadius = definition.radius
        result.circleColor = definition.color
        
        result.circleStrokeWidth = definition.strokeWidth
        result.circleStrokeColor = definition.strokeColor
        
        
        return result
    }
}
