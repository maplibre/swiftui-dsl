import MapLibre
import SwiftUI

#if swift(>=6.2)
    private struct MapViewUnsafeControllerKey: @MainActor EnvironmentKey {
        @MainActor static let defaultValue: ((any MapViewHostViewController) -> Void)? = nil
    }
#else
    private struct MapViewUnsafeControllerKey: EnvironmentKey {
        nonisolated(unsafe) static let defaultValue: ((any MapViewHostViewController) -> Void)? = nil
    }
#endif

@MainActor
extension EnvironmentValues {
    var mapUnsafeController: ((any MapViewHostViewController) -> Void)? {
        get { self[MapViewUnsafeControllerKey.self] }
        set { self[MapViewUnsafeControllerKey.self] = newValue }
    }
}

private struct MapViewUnsafeControllerViewModifier: ViewModifier {
    let unsafeController: (any MapViewHostViewController) -> Void

    func body(content: Content) -> some View {
        content.environment(\.mapUnsafeController, unsafeController)
    }
}

public extension View {
    /// Allows you to set properties of the underlying MLNMapView directly
    /// in cases where these have not been ported to DSL yet.
    /// Use this function to modify various properties of the MLNMapView instance.
    /// For example, you can enable the display of the user's location on the map by setting `showUserLocation` to true.
    ///
    /// This is an 'escape hatch' back to the non-DSL world
    /// of MapLibre for features that have not been ported to DSL yet.
    /// Be careful not to use this to modify properties that are
    /// already ported to the DSL, like the camera for example, as your
    /// modifications here may break updates that occur with modifiers.
    /// In particular, this modifier is potentially dangerous as it runs on
    /// EVERY call to `updateUIView`.
    ///
    /// - Parameter modifier: A closure that provides you with an MLNMapView so you can set properties.
    /// - Returns: A MapView with the modifications applied.
    ///
    /// Example:
    /// ```swift
    ///  MapView()
    ///     .unsafeMapViewControllerModifier { controller in
    ///         controller.mapView.showUserLocation = true
    ///     }
    /// ```
    ///
    @MainActor
    func unsafeMapViewControllerModifier(_ apply: @escaping (any MapViewHostViewController) -> Void) -> some View {
        modifier(MapViewUnsafeControllerViewModifier(unsafeController: apply))
    }
}
