// Various quality-of-life extensions to MapLibre APIs.

import Mapbox

// TODO: Upstream this?
extension MGLPolyline {
    /// Constructs a polyline (aka LineString) from a list of coordinates.
    public convenience init(coordinates: [CLLocationCoordinate2D]) {
        self.init(coordinates: coordinates, count: UInt(coordinates.count))
    }
}
