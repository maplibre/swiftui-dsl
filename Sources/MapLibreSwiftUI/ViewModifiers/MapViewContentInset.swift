import MapLibre
import SwiftUI

#if swift(>=6.2)
    private struct MapViewContentInsetKey: @MainActor EnvironmentKey {
        @MainActor static let defaultValue: UIEdgeInsets? = nil
    }
#else
    private struct MapViewContentInsetKey: EnvironmentKey {
        static let defaultValue: UIEdgeInsets? = nil
    }
#endif

@MainActor
extension EnvironmentValues {
    var mapContentInset: UIEdgeInsets? {
        get { self[MapViewContentInsetKey.self] }
        set { self[MapViewContentInsetKey.self] = newValue }
    }
}

private struct MapViewContentInsetViewModifier: ViewModifier {
    let mapContentInset: UIEdgeInsets

    func body(content: Content) -> some View {
        content.environment(\.mapContentInset, mapContentInset)
    }
}

public extension View {
    
    /// Set the content inset in the map.
    ///
    /// This pads the things like the user location puck.
    ///
    /// - Parameter inset: The edge insets to pad the map content with.
    @MainActor
    func mapViewContentInset(_ inset: UIEdgeInsets) -> some View {
        modifier(MapViewContentInsetViewModifier(mapContentInset: inset))
    }

}
