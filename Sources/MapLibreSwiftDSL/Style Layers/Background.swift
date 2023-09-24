import Foundation
import MapLibre
import InternalUtils
import MapLibreSwiftMacros

// TODO: Other properties and their modifiers
@StyleExpression<UIColor>(named: "backgroundColor", supportsInterpolation: true)
@StyleExpression<Float>(named: "backgroundOpacity", supportsInterpolation: true)
public struct BackgroundLayer: StyleLayer {
    public let identifier: String
    public var insertionPosition: LayerInsertionPosition = .belowOthers
    public var isVisible: Bool = true
    public var maximumZoomLevel: Float? = nil
    public var minimumZoomLevel: Float? = nil

    public init(identifier: String) {
        self.identifier = identifier
    }

    public func makeMGLStyleLayer() -> MLNStyleLayer {
        let result = MLNBackgroundStyleLayer(identifier: identifier)

        result.backgroundColor = backgroundColor
        result.backgroundOpacity = backgroundOpacity

        return result
    }
}
