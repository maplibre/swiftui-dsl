import Foundation

@resultBuilder
public enum MapViewContentBuilder: DefaultResultBuilder {
    public static func buildExpression(_ expression: StyleLayerDefinition) -> [StyleLayerDefinition] {
        return [expression]
    }
    
    public static func buildExpression(_ expression: [StyleLayerDefinition]) -> [StyleLayerDefinition] {
        return expression
    }
    
    public static func buildExpression(_ expression: Void) -> [StyleLayerDefinition] {
        return []
    }
    
    public static func buildBlock(_ components: [StyleLayerDefinition]...) -> [StyleLayerDefinition] {
        return components.flatMap { $0 }
    }
    
    public static func buildArray(_ components: [StyleLayerDefinition]) -> [StyleLayerDefinition] {
        return components
    }
    
    public static func buildArray(_ components: [[StyleLayerDefinition]]) -> [StyleLayerDefinition] {
        return components.flatMap { $0 }
    }
    
    public static func buildEither(first components: [StyleLayerDefinition]) -> [StyleLayerDefinition] {
        return components
    }
    
    public static func buildEither(second components: [StyleLayerDefinition]) -> [StyleLayerDefinition] {
        return components
    }
    
    public static func buildOptional(_ components: [StyleLayerDefinition]?) -> [StyleLayerDefinition] {
        return components ?? []
    }
    
    // MARK: Custom Handler for StyleLayerCollection type.
    
    public static func buildExpression(_ styleCollection: StyleLayerCollection) -> [StyleLayerDefinition] {
        return styleCollection.layers
    }
}
