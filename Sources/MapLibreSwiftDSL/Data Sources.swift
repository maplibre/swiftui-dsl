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
    // Features which retain attributes when styled, filtered via a predicate, etc.
    case features([MLNShape & MLNFeature])
}



public struct ShapeSource: Source {
    public let identifier: String
    let data: ShapeData

    public init(identifier: String, @ShapeDataBuilder _ makeShapeDate: () -> ShapeData) {
        self.identifier = identifier
        self.data = makeShapeDate()
    }

    public func makeMGLSource() -> MLNSource {
        // TODO: Options! These should be represented via modifiers like .clustered()
        switch data {
        case .geoJSONURL(let url):
            return MLNShapeSource(identifier: identifier, url: url)
        case .shapes(let shapes):
            return MLNShapeSource(identifier: identifier, shapes: shapes)
        case .features(let features):
            return MLNShapeSource(identifier: identifier, features: features)
        }
    }
}


@resultBuilder
public enum ShapeDataBuilder {
    // Handle a single MLNShape element
    public static func buildExpression(_ expression: MLNShape) -> [MLNShape] {
        return [expression]
    }
    
    public static func buildExpression(_ expression: [MLNShape]) -> [MLNShape] {
        return expression
    }
    
    // Combine elements into an array
    public static func buildBlock(_ components: [MLNShape]...) -> [MLNShape] {
        return components.flatMap { $0 }
    }
    
    // Handle an array of MLNShape (if you want to directly pass arrays)
    public static func buildArray(_ components: [MLNShape]) -> [MLNShape] {
        return components
    }
    
    // Handle for in of MLNShape
    public static func buildArray(_ components: [[MLNShape]]) -> [MLNShape] {
        return components.flatMap { $0 }
    }
    
    // Convert the collected MLNShape array to ShapeData
    public static func buildFinalResult(_ components: [MLNShape]) -> ShapeData {
        let features = components.compactMap { $0 as? MLNShape & MLNFeature }
        if features.count == components.count {
            return .features(features)
        } else {
            return .shapes(components)
        }
    }
}
