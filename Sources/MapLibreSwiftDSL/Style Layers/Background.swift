import Foundation
import MapLibre
import InternalUtils
import MapLibreSwiftMacros

@MLNStyleProperty<UIColor>("backgroundColor", supportsInterpolation: true)
@MLNStyleProperty<Float>("backgroundOpacity", supportsInterpolation: true)
public struct BackgroundLayer: StyleLayer {
    public let identifier: String
    public var insertionPosition: LayerInsertionPosition = .belowOthers
    public var isVisible: Bool = true
    public var maximumZoomLevel: Float? = nil
    public var minimumZoomLevel: Float? = nil

    public init(identifier: String) {
        self.identifier = identifier
    }

    public func makeMLNStyleLayer() -> MLNStyleLayer {
        let result = MLNBackgroundStyleLayer(identifier: identifier)

        result.backgroundColor = backgroundColor
        result.backgroundOpacity = backgroundOpacity

        return result
    }
}
