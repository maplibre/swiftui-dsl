
// Various quality-of-life extensions to MapLibre APIs.
import MapLibre

// TODO: Upstream this?
public extension MLNPolyline {
    /// Constructs a polyline (aka LineString) from a list of coordinates.
    convenience init(coordinates: [CLLocationCoordinate2D]) {
        self.init(coordinates: coordinates, count: UInt(coordinates.count))
    }
}

public extension MLNPointFeature {
    convenience init(coordinate: CLLocationCoordinate2D, configure: ((MLNPointFeature) -> Void)? = nil) {
        self.init()
        self.coordinate = coordinate

        configure?(self)
    }
}
