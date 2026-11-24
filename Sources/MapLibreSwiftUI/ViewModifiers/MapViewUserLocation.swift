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
    /// Set the visibility of the user location marker without enabling a tracking mode.
    ///
    /// - Parameter isVisible: Whether to display the user's location marker.
    /// - Returns: The modified view hierarchy.
    func mapUserLocationVisible(_ isVisible: Bool) -> some View {
        modifier(MapUserLocationVisibilityViewModifier(isVisible: isVisible))
    }
}
