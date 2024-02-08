import CoreLocation

// TODO: We can delete chat about this. I'm not 100% on it, even though I want Hashable 
// on the MapCameraView (so we can let a user present a MapView with a designated camera from NavigationLink)
extension CLLocationCoordinate2D: Hashable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude
        && lhs.longitude == rhs.longitude
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}
