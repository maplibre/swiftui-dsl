import MapLibre
import SwiftUI

#if swift(>=6.2)
    private struct OnMapStyleLoadedKey: @MainActor EnvironmentKey {
        @MainActor static let defaultValue: ((MLNStyle) -> Void)? = nil
    }
#else
    private struct OnMapStyleLoadedKey: EnvironmentKey {
        nonisolated(unsafe) static let defaultValue: ((MLNStyle) -> Void)? = nil
    }
#endif

@MainActor
extension EnvironmentValues {
    var onMapStyleLoaded: ((MLNStyle) -> Void)? {
        get { self[OnMapStyleLoadedKey.self] }
        set { self[OnMapStyleLoadedKey.self] = newValue }
    }
}

private struct OnMapStyleLoadedViewModifier: ViewModifier {
    let onMapStyleLoaded: (MLNStyle) -> Void

    func body(content: Content) -> some View {
        content.environment(\.onMapStyleLoaded, onMapStyleLoaded)
    }
}

public extension View {
    /// Perform an action when the map view has loaded its style and all locally added style definitions.
    ///
    /// - Parameter perform: The action to perform with the loaded style.
    /// - Returns: The modified map view.
    @MainActor
    func onMapStyleLoaded(_ perform: @escaping (MLNStyle) -> Void) -> some View {
        modifier(OnMapStyleLoadedViewModifier(onMapStyleLoaded: perform))
    }
}
