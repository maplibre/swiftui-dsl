import MapLibre
import MapLibreSwiftDSL
import SwiftUI

#if swift(>=6.2)
    private struct MapViewControlsKey: @MainActor EnvironmentKey {
        @MainActor static let defaultValue: [MapControl] = [
            CompassView(),
            LogoView(),
            AttributionButton(),
        ]
    }
#else
    private struct MapViewControlsKey: EnvironmentKey {
        nonisolated(unsafe) static let defaultValue: [MapControl] = [
            CompassView(),
            LogoView(),
            AttributionButton(),
        ]
    }
#endif

@MainActor
extension EnvironmentValues {
    var mapControls: [MapControl] {
        get { self[MapViewControlsKey.self] }
        set { self[MapViewControlsKey.self] = newValue }
    }
}

private struct MapControlsViewModifier: ViewModifier {
    let controls: [MapControl]

    func body(content: Content) -> some View {
        content.environment(\.mapControls, controls)
    }
}

public extension View {
    /// Customize the MapLibre MapView's Controls.
    ///
    /// - Parameter buildControls: The map controls you want to include.
    @MainActor
    func mapControls(@MapControlsBuilder _ mapLibreMapControls: () -> [MapControl]) -> some View {
        modifier(MapControlsViewModifier(controls: mapLibreMapControls()))
    }
}
