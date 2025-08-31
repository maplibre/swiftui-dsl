import Foundation

public protocol StyleLayerCollection {
    @MapViewContentBuilder var layers: [StyleLayerDefinition] { get }
}

/// Enables more natural "Builder" return value (more like SwiftUI's View)
///
/// Instead of:
/// ```
/// @MapViewContentBuilder mapContent: @escaping () -> [StyleLayerDefinition]
/// ```
/// You can do:
/// ```
/// @MapViewContentBuilder mapContent: @escaping () -> some StyleLayerCollection
/// ```
extension Array: StyleLayerCollection where Element == StyleLayerDefinition {
    public var layers: [StyleLayerDefinition] { self }
}
