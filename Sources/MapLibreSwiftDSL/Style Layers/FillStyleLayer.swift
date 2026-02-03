import Foundation
import InternalUtils
import MapLibre
import MapLibreSwiftMacros

// TODO: Other properties and their modifiers
@MLNStyleProperty<UIColor>("fillColor", supportsInterpolation: true)
@MLNStyleProperty<UIColor>("fillOutlineColor", supportsInterpolation: true)
@MLNStyleProperty<Float>("fillOpacity", supportsInterpolation: true)
public struct FillStyleLayer: SourceBoundVectorStyleLayerDefinition {
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

        return FillStyleLayerInternal(definition: self, mglSource: styleSource)
    }
}

private struct FillStyleLayerInternal: StyleLayer {
    private var definition: FillStyleLayer
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

    init(definition: FillStyleLayer, mglSource: MLNSource) {
        self.definition = definition
        self.mglSource = mglSource
    }

    func makeMLNStyleLayer() -> MLNStyleLayer {
        let result = MLNFillStyleLayer(identifier: identifier, source: mglSource)

        result.fillColor = definition.fillColor
        result.fillOutlineColor = definition.fillOutlineColor
        result.fillOpacity = definition.fillOpacity

        result.predicate = definition.predicate

        return result
    }
}
