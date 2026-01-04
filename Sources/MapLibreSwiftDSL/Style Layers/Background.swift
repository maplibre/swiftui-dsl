import Foundation
import InternalUtils
import MapLibre
import MapLibreSwiftMacros

@MLNStyleProperty<UIColor>("backgroundColor", supportsInterpolation: true)
@MLNStyleProperty<Float>("backgroundOpacity", supportsInterpolation: true)
public struct BackgroundLayer: StyleLayer {
    public let identifier: String
    public var insertionPosition: LayerInsertionPosition = .below(.all)
    public var isVisible: Bool = true
    public var maximumZoomLevel: Float?
    public var minimumZoomLevel: Float?

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
