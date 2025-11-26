import SwiftUI

private struct MapViewContentUserAnnotationStyleKey: EnvironmentKey {
    static let defaultValue = MapUserAnnotationStyle()
}

extension EnvironmentValues {
    var mapViewUserAnnotationStyle: MapUserAnnotationStyle {
        get { self[MapViewContentUserAnnotationStyleKey.self] }
        set { self[MapViewContentUserAnnotationStyleKey.self] = newValue }
    }
}

private struct MapUserAnnotationStyleViewModifier: ViewModifier {
    let userAnnotationStyle: MapUserAnnotationStyle

    func body(content: Content) -> some View {
        content.environment(\.mapViewUserAnnotationStyle, userAnnotationStyle)
    }
}

public extension View {
    /// Customize the MapLibre MapView user location annotation style
    ///
    /// - Parameter annotationStyle: The customized annotation style.
    /// - Returns: The modified view heirarchy
    func mapUserAnnotationStyle(_ annotationStyle: MapUserAnnotationStyle) -> some View {
        modifier(MapUserAnnotationStyleViewModifier(userAnnotationStyle: annotationStyle))
    }
}
