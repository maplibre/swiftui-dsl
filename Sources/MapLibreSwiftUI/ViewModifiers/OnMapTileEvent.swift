import SwiftUI

#if swift(>=6.2)
    private struct OnMapTileEventKey: @MainActor EnvironmentKey {
        @MainActor static let defaultValue: (@MainActor (MapTileEvent) -> Void)? = nil
    }
#else
    private struct OnMapTileEventKey: EnvironmentKey {
        nonisolated(unsafe) static let defaultValue: (@MainActor (MapTileEvent) -> Void)? = nil
    }
#endif

@MainActor
extension EnvironmentValues {
    var onMapTileEvent: (@MainActor (MapTileEvent) -> Void)? {
        get { self[OnMapTileEventKey.self] }
        set { self[OnMapTileEventKey.self] = newValue }
    }
}

private struct OnMapTileEventViewModifier: ViewModifier {
    let onMapTileEvent: @MainActor (MapTileEvent) -> Void

    func body(content: Content) -> some View {
        content.environment(\.onMapTileEvent, onMapTileEvent)
    }
}

@MainActor
public extension View {
    /// Observes every tile lifecycle operation from this map view.
    ///
    /// The action runs on the main actor.
    /// It receives every repeated event without debouncing or deduplication.
    /// Keep the action brief because MapLibre can report many tile operations.
    /// Use `event.operation == .requestedFromNetwork` to count network tile requests.
    ///
    /// - Parameter perform: The action to perform with the tile operation and source identifier.
    /// - Returns: A view with the tile event action in its environment.
    func onMapTileEvent(_ perform: @escaping @MainActor (MapTileEvent) -> Void) -> some View {
        modifier(OnMapTileEventViewModifier(onMapTileEvent: perform))
    }
}
