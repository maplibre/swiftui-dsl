import SwiftUI

#if swift(>=6.2)
    private struct OnMapIdleKey: @MainActor EnvironmentKey {
        @MainActor static let defaultValue: ((MapViewProxy) -> Void)? = nil
    }
#else
    private struct OnMapIdleKey: EnvironmentKey {
        nonisolated(unsafe) static let defaultValue: ((MapViewProxy) -> Void)? = nil
    }
#endif

@MainActor
extension EnvironmentValues {
    var onMapIdle: ((MapViewProxy) -> Void)? {
        get { self[OnMapIdleKey.self] }
        set { self[OnMapIdleKey.self] = newValue }
    }
}

private struct OnMapIdleViewModifier: ViewModifier {
    let onMapIdle: (MapViewProxy) -> Void

    func body(content: Content) -> some View {
        content.environment(\.onMapIdle, onMapIdle)
    }
}

@MainActor
public extension View {
    /// Perform an action when the map becomes idle.
    ///
    /// This callback is emitted from the underlying `mapViewDidBecomeIdle` delegate event.
    /// - Parameter perform: The action to perform with a read-only proxy of the current map state.
    /// - Returns: The modified map view.
    func onMapIdle(_ perform: @escaping (MapViewProxy) -> Void) -> some View {
        modifier(OnMapIdleViewModifier(onMapIdle: perform))
    }
}
