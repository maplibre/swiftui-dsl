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
public extension EnvironmentValues {
    /// The style-loaded handler supplied by this view's parent.
    ///
    /// Wrapper views can read and forward it alongside their own handler when
    /// installing an internal `onMapStyleLoaded` modifier. The modifier retains
    /// its existing nearest-handler semantics.
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

    /// Perform an action after a map render pass has finished.
    ///
    /// - Parameter perform: The action to perform with the current map view proxy and render completeness flag.
    /// - Returns: The modified map view.
    @MainActor
    func onMapDidFinishRendering(
        _ perform: @escaping (MapViewProxy, Bool) -> Void
    ) -> some View {
        modifier(OnMapDidFinishRenderingViewModifier(onMapDidFinishRendering: perform))
    }
}

#if swift(>=6.2)
    private struct OnMapDidFinishRenderingMapKey: @MainActor EnvironmentKey {
        @MainActor static let defaultValue: ((MapViewProxy, Bool) -> Void)? = nil
    }
#else
    private struct OnMapDidFinishRenderingMapKey: EnvironmentKey {
        nonisolated(unsafe) static let defaultValue: ((MapViewProxy, Bool) -> Void)? = nil
    }
#endif

@MainActor
extension EnvironmentValues {
    var onMapDidFinishRendering: ((MapViewProxy, Bool) -> Void)? {
        get { self[OnMapDidFinishRenderingMapKey.self] }
        set { self[OnMapDidFinishRenderingMapKey.self] = newValue }
    }
}

private struct OnMapDidFinishRenderingViewModifier: ViewModifier {
    let onMapDidFinishRendering: (MapViewProxy, Bool) -> Void

    func body(content: Content) -> some View {
        content.environment(\.onMapDidFinishRendering, onMapDidFinishRendering)
    }
}
