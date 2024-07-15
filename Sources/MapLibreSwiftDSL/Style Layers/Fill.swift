// import Foundation
// import MapLibre
// import InternalUtils
// import MapLibreSwiftMacros
//
//// TODO: background opacity property (and resolved image properties in general)
//// TODO: Generalization: color properties and numeric properties
// @MLNStyleProperty<UIColor>("backgroundColor", supportsInterpolation: true)
// @MLNStyleProperty<Float>("backgroundOpacity", supportsInterpolation: true)
// public struct FillLayer: SourceBoundStyleLayerDefinition {
//    public let identifier: String
//    public var insertionPosition: LayerInsertionPosition = .belowOthers
//    public var isVisible: Bool = true
//    public var maximumZoomLevel: Float? = nil
//    public var minimumZoomLevel: Float? = nil
//
//    public var source: StyleLayerSource
//
//    public init(identifier: String, source: Source) {
//        self.identifier = identifier
//        self.source = .source(source)
//    }
//
//    public init(identifier: String, source: MLNSource) {
//        self.identifier = identifier
//        self.source = .mglSource(source)
//    }
//
//    public func makeStyleLayer(style: MLNStyle) -> StyleLayer {
//        let styleSource = addSource(to: style)
//
//        let result = MLNFillStyleLayer(identifier: identifier, source: source)
//
//        // TODO: Macro-ize this
//        result.backgroundColor = backgroundColor
//        result.backgroundOpacity = backgroundOpacity
//
//        return result
//    }
// }
