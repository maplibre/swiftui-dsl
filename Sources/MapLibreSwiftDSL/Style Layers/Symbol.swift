import Foundation
import InternalUtils
import MapLibre
import MapLibreSwiftMacros

/// A MapLibre symbol.
///
/// An enum would probably be better for iconAnchor and textAnchor?
@MLNStyleProperty<Double>("iconRotation", supportsInterpolation: true)
@MLNStyleProperty<UIColor>("iconColor", supportsInterpolation: true)
@MLNStyleProperty<Bool>("iconAllowsOverlap", supportsInterpolation: false)
@MLNStyleProperty<CGVector>("iconOffset", supportsInterpolation: true)
@MLNStyleProperty<String>("iconAnchor", supportsInterpolation: false)

@MLNStyleProperty<UIColor>("textColor", supportsInterpolation: true)
@MLNStyleProperty<Double>("textFontSize", supportsInterpolation: true)
@MLNStyleProperty<String>("text", supportsInterpolation: false)
@MLNStyleProperty<[String]>("textFontNames", supportsInterpolation: false)
@MLNStyleProperty<String>("textAnchor", supportsInterpolation: false)
@MLNStyleProperty<CGVector>("textOffset", supportsInterpolation: true)
@MLNStyleProperty<Double>("maximumTextWidth", supportsInterpolation: true)
@MLNStyleProperty<Bool>("textAllowsOverlap", supportsInterpolation: false)

@MLNStyleProperty<UIColor>("textHaloColor", supportsInterpolation: true)
@MLNStyleProperty<Double>("textHaloWidth", supportsInterpolation: true)
@MLNStyleProperty<Double>("textHaloBlur", supportsInterpolation: true)

@MLNStyleProperty<String>("symbolPlacement", supportsInterpolation: false)
@MLNStyleProperty<Double>("symbolSpacing", supportsInterpolation: true)

public struct SymbolStyleLayer: SourceBoundVectorStyleLayerDefinition {
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
        sourceLayerIdentifier = nil
        self.source = .source(source)
    }

    public init(identifier: String, source: MLNSource, sourceLayerIdentifier: String? = nil) {
        self.identifier = identifier
        self.sourceLayerIdentifier = sourceLayerIdentifier
        self.source = .mglSource(source)
    }

    public func makeStyleLayer(style: MLNStyle) -> StyleLayer {
        let styleSource = addSource(to: style)

        // Register the images with the map style
        for image in iconImages {
            style.setImage(image, forName: image.sha256())
        }
        return SymbolStyleLayerInternal(definition: self, mglSource: styleSource)
    }

    public var iconImageName: NSExpression?

    public var iconImages = [UIImage]()

    // MARK: - Modifiers

    public func iconImage(_ image: UIImage) -> Self {
        modified(self) { it in
            it.iconImageName = NSExpression(forConstantValue: image.sha256())
            it.iconImages = [image]
        }
    }

    public func iconImage(featurePropertyNamed keyPath: String) -> Self {
        var copy = self
        copy.iconImageName = NSExpression(forKeyPath: keyPath)
        return copy
    }

    /// Add an icon image that can be dynamic and use UIImages in your app, based on a feature property of the source.
    /// For example, your feature could have a property called "icon-name". This name is then resolved against the key
    /// in the mappings dictionary and used to find a UIImage to display on the map for that feature.
    /// - Parameters:
    ///   - keyPath: The keypath to the feature property containing the icon to use, for example "icon-name".
    ///   - mappings: A lookup dictionary containing the keys found in "keyPath" and a UIImage for each keyPath. The key
    /// of the mappings dictionary needs to match the value type stored at keyPath, for example `String`.
    ///   - defaultImage: A UIImage that MapLibre should fall back to if the key in your feature is not found in the
    /// mappings table
    public func iconImage(
        featurePropertyNamed keyPath: String,
        mappings: [AnyHashable: UIImage],
        default defaultImage: UIImage
    ) -> Self {
        modified(self) { it in
            let attributeExpression = NSExpression(forKeyPath: keyPath)
            let mappingExpressions = mappings.mapValues { image in
                NSExpression(forConstantValue: image.sha256())
            }
            let mappingDictionary = NSDictionary(dictionary: mappingExpressions)
            let defaultExpression = NSExpression(forConstantValue: defaultImage.sha256())

            it.iconImageName = NSExpression(
                forMLNMatchingKey: attributeExpression,
                in: mappingDictionary as! [NSExpression: NSExpression],
                default: defaultExpression
            )
            it.iconImages = mappings.values + [defaultImage]
        }
    }
}

private struct SymbolStyleLayerInternal: StyleLayer {
    private var definition: SymbolStyleLayer
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

    init(definition: SymbolStyleLayer, mglSource: MLNSource) {
        self.definition = definition
        self.mglSource = mglSource
    }

    func makeMLNStyleLayer() -> MLNStyleLayer {
        let result = MLNSymbolStyleLayer(identifier: identifier, source: mglSource)
        result.sourceLayerIdentifier = definition.sourceLayerIdentifier

        result.iconImageName = definition.iconImageName
        result.iconRotation = definition.iconRotation
        result.iconAllowsOverlap = definition.iconAllowsOverlap
        result.iconColor = definition.iconColor
        result.iconOffset = definition.iconOffset
        result.iconAnchor = definition.iconAnchor

        result.text = definition.text
        result.textColor = definition.textColor
        result.textFontSize = definition.textFontSize
        result.maximumTextWidth = definition.maximumTextWidth
        result.textAnchor = definition.textAnchor
        result.textOffset = definition.textOffset
        result.textFontNames = definition.textFontNames
        result.textAllowsOverlap = definition.textAllowsOverlap

        result.textHaloColor = definition.textHaloColor
        result.textHaloWidth = definition.textHaloWidth
        result.textHaloBlur = definition.textHaloBlur

        result.symbolPlacement = definition.symbolPlacement
        result.symbolSpacing = definition.symbolSpacing

        result.predicate = definition.predicate

        if let minimumZoomLevel = definition.minimumZoomLevel {
            result.minimumZoomLevel = minimumZoomLevel
        }

        if let maximumZoomLevel = definition.maximumZoomLevel {
            result.maximumZoomLevel = maximumZoomLevel
        }

        return result
    }
}
