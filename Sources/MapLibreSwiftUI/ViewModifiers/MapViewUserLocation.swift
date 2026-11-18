import SwiftUI

private struct MapUserLocationVisibilityKey: EnvironmentKey {
    static let defaultValue: Bool? = nil
}

extension EnvironmentValues {
    var mapUserLocationVisibility: Bool? {
        get { self[MapUserLocationVisibilityKey.self] }
        set { self[MapUserLocationVisibilityKey.self] = newValue }
    }
}

private struct MapUserLocationVisibilityViewModifier: ViewModifier {
    let isVisible: Bool

    func body(content: Content) -> some View {
        content.environment(\.mapUserLocationVisibility, isVisible)
    }
}

public extension View {
    /// Sets whether the map displays the user's location, without choosing a camera mode.
    ///
    /// The value is applied after the location manager is installed and when the requested visibility changes.
    /// Unchanged updates leave Native's location-error handling intact.
    /// Hiding stops native tracking; showing the location does not restore tracking.
    /// A subsequent follow-camera request can show the location, following MapLibre Native's behavior.
    /// Omitting or removing the modifier leaves the current native settings unchanged.
    ///
    /// - Parameter isVisible: Whether to display the user's location.
    /// - Returns: The modified view hierarchy.
    func mapUserLocationVisible(_ isVisible: Bool) -> some View {
        modifier(MapUserLocationVisibilityViewModifier(isVisible: isVisible))
    }
}
