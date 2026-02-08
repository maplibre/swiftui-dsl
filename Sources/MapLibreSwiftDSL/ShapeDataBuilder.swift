import Foundation
import MapLibre

/// A description of a data source for layers in a MapLibre style.
public protocol Source {
    /// A string that uniquely identifies the source in the style to which it is added.
    var identifier: String { get }

    func makeMGLSource() -> MLNSource
}

/// A description of the data underlying an ``MLNShapeSource``.
public enum ShapeData {
    /// A URL from which to load GeoJSON.
    case geoJSONURL(URL)
    /// Generic shapes. These will NOT preserve any attributes.
    case shapes([MLNShape])
    /// Features which retain attributes when styled, filtered via a predicate, etc.
    case features([MLNShape & MLNFeature])
}

public struct ShapeSource: Source {
    public let identifier: String
    public let options: [MLNShapeSourceOption: Any]?
    let data: ShapeData

    public init(
        identifier: String,
        options: [MLNShapeSourceOption: Any]? = nil,
        @ShapeDataBuilder _ makeShapeDate: () -> ShapeData
    ) {
        self.identifier = identifier
        self.options = options
        data = makeShapeDate()
    }

    public func makeMGLSource() -> MLNSource {
        // TODO: Options! These should be represented via modifiers like .clustered()
        switch data {
        case let .geoJSONURL(url):
            MLNShapeSource(identifier: identifier, url: url, options: options)
        case let .shapes(shapes):
            MLNShapeSource(identifier: identifier, shapes: shapes, options: options)
        case let .features(features):
            MLNShapeSource(identifier: identifier, features: features, options: options)
        }
    }
}

@resultBuilder
public enum ShapeDataBuilder: DefaultResultBuilder {
    public static func buildExpression(_ expression: MLNShape) -> [MLNShape] {
        [expression]
    }

    public static func buildExpression(_ expression: [MLNShape]) -> [MLNShape] {
        expression
    }

    public static func buildExpression(_: Void) -> [MLNShape] {
        []
    }

    public static func buildBlock(_ components: [MLNShape]...) -> [MLNShape] {
        components.flatMap { $0 }
    }

    public static func buildArray(_ components: [MLNShape]) -> [MLNShape] {
        components
    }

    public static func buildArray(_ components: [[MLNShape]]) -> [MLNShape] {
        components.flatMap { $0 }
    }

    public static func buildEither(first components: [MLNShape]) -> [MLNShape] {
        components
    }

    public static func buildEither(second components: [MLNShape]) -> [MLNShape] {
        components
    }

    public static func buildOptional(_ components: [MLNShape]?) -> [MLNShape] {
        components ?? []
    }

    /// Convert the collected MLNShape array to ShapeData
    public static func buildFinalResult(_ components: [MLNShape]) -> ShapeData {
        let features = components.compactMap { $0 as? MLNShape & MLNFeature }
        if features.count == components.count {
            return .features(features)
        } else {
            return .shapes(components)
        }
    }
}
