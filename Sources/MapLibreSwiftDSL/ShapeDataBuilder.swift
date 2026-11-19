import Foundation
import MapLibre

/// A description of a data source for layers in a MapLibre style.
public protocol Source {
    /// A string that uniquely identifies the source in the style to which it is added.
    var identifier: String { get }

    func makeMGLSource() -> MLNSource

    /// Updates the data of `source` in place, redrawing it on the map.
    ///
    /// The map view calls this method on each SwiftUI update and when this definition equals `previous`.
    /// The default implementation returns `false`, so the map view replaces the source and adds its layers
    /// again on each update. Implement this method to change the source in place.
    ///
    /// - Parameters:
    ///   - source: The source in the style.
    ///   - previous: The definition that `source` shows.
    /// - Returns: Whether the source reflects the latest data.
    func update(_ source: MLNSource, from previous: Source) -> Bool
}

public extension Source {
    func update(_: MLNSource, from _: Source) -> Bool {
        false
    }
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

extension ShapeData: Equatable {
    public static func == (lhs: ShapeData, rhs: ShapeData) -> Bool {
        switch (lhs, rhs) {
        case let (.geoJSONURL(lhs), .geoJSONURL(rhs)):
            lhs == rhs
        case let (.shapes(lhs), .shapes(rhs)):
            lhs == rhs
        case let (.features(lhs), .features(rhs)):
            lhs.elementsEqual(rhs) { $0.isEqual($1) }
        default:
            false
        }
    }
}

/// A shape source with content that the map view updates when the definition changes.
///
/// To change the content, give new shape objects. The map view compares shapes with `isEqual(_:)`, so it
/// does not see a change to a shape object that it already holds.
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

    public func update(_ source: MLNSource, from previous: Source) -> Bool {
        guard let source = source as? MLNShapeSource,
              let previous = previous as? ShapeSource
        else {
            return false
        }

        guard NSDictionary(dictionary: options ?? [:]).isEqual(to: previous.options ?? [:]) else {
            // Require the options to match, otherwise we assume it's a different source.
            return false
        }

        if data == previous.data {
            // Already up to date, exit.
            return true
        }

        switch data {
        case let .geoJSONURL(url):
            source.url = url
        case let .shapes(shapes):
            source.shape = MLNShapeCollection(shapes: shapes)
        case let .features(features):
            source.shape = MLNShapeCollectionFeature(shapes: features)
        }
        return true
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
