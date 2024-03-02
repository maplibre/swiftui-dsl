import Foundation

public protocol StyleLayerCollection {
    @MapViewContentBuilder var layers: [StyleLayerDefinition] { get }
}
