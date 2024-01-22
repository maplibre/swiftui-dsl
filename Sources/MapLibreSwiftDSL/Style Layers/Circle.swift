import Foundation
import InternalUtils
import MapLibre
import MapLibreSwiftMacros

@MLNStyleProperty<Double>("circleRadius", supportsInterpolation: true)
@MLNStyleProperty<UIColor>("circleColor", supportsInterpolation: false)
@MLNStyleProperty<Double>("circleStrokeWidth", supportsInterpolation: true)
@MLNStyleProperty<UIColor>("circleStrokeColor", supportsInterpolation: true)
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
        
        // Register the images with the map style
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
        
        result.circleRadius = definition.circleRadius
        
        result.circleStrokeColor = definition.circleStrokeColor
        result.circleStrokeWidth = definition.circleStrokeWidth
        
        result.circleColor = definition.circleColor
        
        return result
    }
}
