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
extension [StyleLayerDefinition]: StyleLayerCollection {
    public var layers: [StyleLayerDefinition] {
        self
    }
}
