import Foundation

public protocol StyleLayerCollection {
    
//    associatedtype Layer : StyleLayerDefinition

    @MapViewContentBuilder var layers: [StyleLayerDefinition] { get }
}
