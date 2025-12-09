import MapLibre
import SwiftUI

#if swift(>=6.2)
    private struct MapViewProxyUpdateMode: @MainActor EnvironmentKey {
        @MainActor static let defaultValue: ProxyUpdateMode? = nil
    }

    private struct OnMapProxyUpdatedKey: @MainActor EnvironmentKey {
        @MainActor static let defaultValue: ((MapViewProxy) -> Void)? = nil
    }
#else
    private struct MapViewProxyUpdateMode: @MainActor EnvironmentKey {
        nonisolated(unsafe) static let defaultValue: ProxyUpdateMode? = nil
    }

    private struct OnMapProxyUpdatedKey: EnvironmentKey {
        nonisolated(unsafe) static let defaultValue: ((MapViewProxy) -> Void)? = nil
    }
#endif

@MainActor
extension EnvironmentValues {
    var mapProxyUpdateMode: ProxyUpdateMode? {
        get { self[MapViewProxyUpdateMode.self] }
        set { self[MapViewProxyUpdateMode.self] = newValue }
    }

    var onMapProxyUpdated: ((MapViewProxy) -> Void)? {
        get { self[OnMapProxyUpdatedKey.self] }
        set { self[OnMapProxyUpdatedKey.self] = newValue }
    }
}

private struct OnMapProxyUpdateViewModifier: ViewModifier {
    let mapProxyUpdateMode: ProxyUpdateMode
    let onMapProxyUpdated: (MapViewProxy) -> Void

    func body(content: Content) -> some View {
        content
            .environment(\.mapProxyUpdateMode, mapProxyUpdateMode)
            .environment(\.onMapProxyUpdated, onMapProxyUpdated)
    }
}

public extension View {
    /// The view modifier recieves an instance of `MapViewProxy`, which contains read only information about the current
    /// state of the `MapView` such as its bounds, center and insets.
    ///
    /// ```swift
    /// MapView()
    ///     .onMapViewProxyUpdate() { proxy in
    ///         print("The map zoom level is: \(proxy.zoomLevel)")
    ///     }
    /// ```
    ///
    /// - Parameters:
    ///   - updateMode: How frequently the `MapViewProxy` is updated. Per default this is set to `.onFinish`, so updates
    ///                 are only sent when the map finally completes updating due to animations or scrolling. Can be set
    /// to `.realtime`
    ///                 to recieve updates during the animations and scrolling too.
    ///   - onViewProxyChanged: The closure containing the `MapViewProxy`. Use this to run code based on the current
    @MainActor
    func onMapViewProxyUpdate(
        updateMode: ProxyUpdateMode = .onFinish,
        onViewProxyChanged: @escaping (MapViewProxy) -> Void
    ) -> some View {
        modifier(OnMapProxyUpdateViewModifier(
            mapProxyUpdateMode: updateMode,
            onMapProxyUpdated: onViewProxyChanged
        ))
    }
}
