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
    /// Customize the Map's Controls.
    ///
    /// - Parameter buildControls: <#buildControls description#>
    /// - Returns: <#description#>
    @MainActor
    func mapControls(@MapControlsBuilder _ buildControls: () -> [MapControl]) -> some View {
        modifier(MapControlsViewModifier(controls: buildControls()))
    }
}
