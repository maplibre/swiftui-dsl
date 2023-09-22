import Foundation
import MapLibre
import InternalUtils

public struct BackgroundLayer: StyleLayer {
    public let identifier: String
    public var insertionPosition: LayerInsertionPosition = .belowOthers
    public var isVisible: Bool = true
    public var maximumZoomLevel: Float? = nil
    public var minimumZoomLevel: Float? = nil

    // TODO: Other properties and their modifiers
    private var backgroundColor: NSExpression = NSExpression(forConstantValue: UIColor.black)
    private var backgroundOpacity: NSExpression = NSExpression(forConstantValue: 1.0)


    public init(identifier: String) {
        self.identifier = identifier
    }

    public func makeMGLStyleLayer() -> MLNStyleLayer {
        let result = MLNBackgroundStyleLayer(identifier: identifier)

        result.backgroundColor = backgroundColor
        result.backgroundOpacity = backgroundOpacity

        return result
    }

    // MARK: - Modifiers

    // TODO: Generalize complex expression variants using macros? Revisit once Swift 5.9 lands
    public func backgroundColor(_ color: UIColor) -> Self {
        return modified(self) { $0.backgroundColor = NSExpression(forConstantValue: color) }
    }

    // TODO: Generalize complex expression variants using macros? Revisit once Swift 5.9 lands
    public func backgroundOpacity(_ opacity: Float) -> Self {
        return modified(self) { $0.backgroundOpacity = NSExpression(forConstantValue: opacity) }
    }
}
