import Foundation
import Mapbox

/// A description of a data source for layers in a MapLibre style.
public protocol Source {
    /// A string that uniquely identifies the source in the style to which it is added.
    var identifier: String { get }

    func makeMGLSource() -> MGLSource
}

/// A description of the data underlying an ``MGLShapeSource``.
public enum ShapeData {
    /// A URL from which to load GeoJSON.
    case geoJSONURL(URL)
    /// Generic shapes. These will NOT preserve any attributes.
    case shapes([MGLShape])
    // Features which retain attributes when styled, filtered via a predicate, etc.
    case features([MGLShape & MGLFeature])
}



public struct ShapeSource: Source {
    public let identifier: String
    let data: ShapeData

    public init(identifier: String, @ShapeDataBuilder _ makeShapeDate: () -> ShapeData) {
        self.identifier = identifier
        self.data = makeShapeDate()
    }

    public func makeMGLSource() -> MGLSource {
        // TODO: Options! These should be represented via modifiers like .clustered()
        switch data {
        case .geoJSONURL(let url):
            return MGLShapeSource(identifier: identifier, url: url)
        case .shapes(let shapes):
            return MGLShapeSource(identifier: identifier, shapes: shapes)
        case .features(let features):
            return MGLShapeSource(identifier: identifier, features: features)
        }
    }
}


@resultBuilder
enum ShapeDataBuilder {
    static func buildBlock(_ components: MGLShape...) -> ShapeData {
        let features = components.compactMap({ $0 as? MGLShape & MGLFeature })

        if features.count == components.count {
            return .features(features)
        } else {
            return .shapes(components)
        }
    }
}
