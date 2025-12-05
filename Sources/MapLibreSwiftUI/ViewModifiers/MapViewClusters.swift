import MapLibre
import SwiftUI

#if swift(>=6.2)
    private struct MapViewClusterLayersKey: @MainActor EnvironmentKey {
        @MainActor static let defaultValue: [ClusterLayer]? = nil
    }
#else
    private struct MapViewClusterLayersKey: EnvironmentKey {
        nonisolated(unsafe) static let defaultValue: [ClusterLayer]? = nil
    }
#endif

@MainActor
extension EnvironmentValues {
    var mapClusterLayers: [ClusterLayer]? {
        get { self[MapViewClusterLayersKey.self] }
        set { self[MapViewClusterLayersKey.self] = newValue }
    }
}

private struct MapViewClusterLayersViewModifier: ViewModifier {
    let clusteredLayers: [ClusterLayer]

    func body(content: Content) -> some View {
        content.environment(\.mapClusterLayers, clusteredLayers)
    }
}

public extension View {
    /// Add a default implementation for tapping clustered features. When tapped, the map zooms so that the cluster is
    /// expanded.
    /// - Parameter clusteredLayers: An array of layers to monitor that can contain clustered features.
    /// - Returns: The modified MapView
    @MainActor
    func mapClustersExpandOnTapping(clusteredLayers: [ClusterLayer]) -> some View {
        modifier(MapViewClusterLayersViewModifier(clusteredLayers: clusteredLayers))
    }
}
