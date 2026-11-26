import MapLibre

extension MLNCoordinateBounds {
    static func arrange(
        sw: CLLocationCoordinate2D = .init(),
        ne: CLLocationCoordinate2D = .init()
    ) -> Self {
        Self(sw: sw, ne: ne)
    }
}
