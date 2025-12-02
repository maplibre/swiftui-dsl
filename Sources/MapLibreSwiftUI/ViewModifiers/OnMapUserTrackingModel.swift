import MapLibre
import SwiftUI

private struct OnMapUserTrackingModeChangedKey: EnvironmentKey {
    @MainActor static let defaultValue: ((MLNUserTrackingMode, Bool) -> Void)? = nil
}

@MainActor
extension EnvironmentValues {
    var onMapUserTrackingModeChanged: ((MLNUserTrackingMode, Bool) -> Void)? {
        get { self[OnMapUserTrackingModeChangedKey.self] }
        set { self[OnMapUserTrackingModeChangedKey.self] = newValue }
    }
}

private struct OnMapStyleLoadedViewModifier: ViewModifier {
    let onMapUserTrackingModeChanged: (MLNUserTrackingMode, Bool) -> Void

    func body(content: Content) -> some View {
        content.environment(\.onMapUserTrackingModeChanged, onMapUserTrackingModeChanged)
    }
}

public extension View {
    /// Perform an action when the map view's user tracking mode has changed
    ///
    /// - Parameter perform: The action to perform on tracking mode change. Inputs are the new user tracking mode and
    /// whether the change was animated.
    @MainActor
    func onMapUserTrackingModeChanged(_ perform: @escaping (MLNUserTrackingMode, Bool) -> Void) -> some View {
        modifier(OnMapStyleLoadedViewModifier(onMapUserTrackingModeChanged: perform))
    }
}
