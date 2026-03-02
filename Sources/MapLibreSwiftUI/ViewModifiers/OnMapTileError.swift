import SwiftUI

#if swift(>=6.2)
    private struct OnMapTileErrorKey: @MainActor EnvironmentKey {
        @MainActor static let defaultValue: (() -> Void)? = nil
    }
#else
    private struct OnMapTileErrorKey: EnvironmentKey {
        nonisolated(unsafe) static let defaultValue: (() -> Void)? = nil
    }
#endif

@MainActor
extension EnvironmentValues {
    var onMapTileError: (() -> Void)? {
        get { self[OnMapTileErrorKey.self] }
        set { self[OnMapTileErrorKey.self] = newValue }
    }
}

private struct OnMapTileErrorViewModifier: ViewModifier {
    let onMapTileError: () -> Void

    func body(content: Content) -> some View {
        content.environment(\.onMapTileError, onMapTileError)
    }
}

public extension View {
    /// Perform an action when one or more map tiles fail to load.
    ///
    /// This is typically triggered by no internet connection or a poor
    /// connection that causes tile requests to time out. MapLibre serves
    /// tiles from its on-device cache when available, so this only fires
    /// for tiles that are not cached locally.
    ///
    /// The callback is debounced to 3ms, a burst of simultaneously
    /// failing tiles within the window produces a single notification
    /// rather than many.
    ///
    /// ```swift
    /// MapView(...)
    ///     .onMapTileError {
    ///         print("Some tiles couldn't load. Check your connection.")
    ///     }
    /// ```
    @MainActor
    func onMapTileError(_ perform: @escaping () -> Void) -> some View {
        modifier(OnMapTileErrorViewModifier(onMapTileError: perform))
    }
}
