import Foundation

@resultBuilder
public enum MapViewContentBuilder: DefaultResultBuilder {
    public static func buildExpression(_ expression: StyleLayerDefinition) -> [StyleLayerDefinition] {
        [expression]
    }

    public static func buildExpression(_ expression: [StyleLayerDefinition]) -> [StyleLayerDefinition] {
        expression
    }

    public static func buildExpression(_: Void) -> [StyleLayerDefinition] {
        []
    }

    public static func buildBlock(_ components: [StyleLayerDefinition]...) -> [StyleLayerDefinition] {
        components.flatMap { $0 }
    }

    public static func buildArray(_ components: [StyleLayerDefinition]) -> [StyleLayerDefinition] {
        components
    }

    public static func buildArray(_ components: [[StyleLayerDefinition]]) -> [StyleLayerDefinition] {
        components.flatMap { $0 }
    }

    public static func buildEither(first components: [StyleLayerDefinition]) -> [StyleLayerDefinition] {
        components
    }

    public static func buildEither(second components: [StyleLayerDefinition]) -> [StyleLayerDefinition] {
        components
    }

    public static func buildOptional(_ components: [StyleLayerDefinition]?) -> [StyleLayerDefinition] {
        components ?? []
    }

    // MARK: Custom Handler for StyleLayerCollection type.

    public static func buildExpression(_ styleCollection: StyleLayerCollection) -> [StyleLayerDefinition] {
        styleCollection.layers
    }
}
