import Foundation

@resultBuilder
public enum MapViewContentBuilder {
    
    public static func buildBlock(_ layers: [StyleLayerDefinition]...) -> [StyleLayerDefinition] {
        return layers.flatMap { $0 }
    }

    public static func buildOptional(_ layers: [StyleLayerDefinition]?) -> [StyleLayerDefinition] {
        return layers ?? []
    }
    
    public static func buildExpression(_ layer: StyleLayerDefinition) -> [StyleLayerDefinition] {
        return [layer]
    }
    
    public static func buildExpression(_ expression: Void) -> [StyleLayerDefinition] {
        return []
    }
    
    public static func buildExpression(_ styleCollection: StyleLayerCollection) -> [StyleLayerDefinition] {
        return styleCollection.layers
    }
    
    // Handle an array of MLNShape (if you want to directly pass arrays)
    public static func buildArray(_ layer: [StyleLayerDefinition]) -> [StyleLayerDefinition] {
        return layer
    }
    
    // Handle for in of MLNShape
    public static func buildArray(_ layer: [[StyleLayerDefinition]]) -> [StyleLayerDefinition] {
        return layer.flatMap { $0 }
    }
    
    public static func buildEither(first layer: [StyleLayerDefinition]) -> [StyleLayerDefinition] {
        return layer
    }
    
    public static func buildEither(second layer: [StyleLayerDefinition]) -> [StyleLayerDefinition] {
        return layer
    }
}
