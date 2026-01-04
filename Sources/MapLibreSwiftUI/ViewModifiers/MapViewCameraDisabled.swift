import MapLibre
import SwiftUI

private struct MapViewCameraDisabledKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

@MainActor
extension EnvironmentValues {
    var mapCameraDisabled: Bool {
        get { self[MapViewCameraDisabledKey.self] }
        set { self[MapViewCameraDisabledKey.self] = newValue }
    }
}

private struct MapViewCameraDisabledViewModifier: ViewModifier {
    let cameraDisabled: Bool

    func body(content: Content) -> some View {
        content.environment(\.mapCameraDisabled, cameraDisabled)
    }
}

public extension View {
    /// Prevent Maplibre-DSL from updating the camera, useful when the underlying ViewController is managing the camera,
    /// for example during navigation when Maplibre-Navigation is used.
    ///
    /// - Parameter disabled: if true, prevents Maplibre-DSL from updating the camera
    @MainActor
    func mapCameraDisabled(_ disabled: Bool) -> some View {
        modifier(MapViewCameraDisabledViewModifier(cameraDisabled: disabled))
    }
}
