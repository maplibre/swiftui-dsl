import Foundation
import CoreLocation

/// A representation of the MapView's current ViewPort.
///
/// This includes similar data to the MapViewCamera, but represents the raw
/// values associated with the MapView. This information could used to prepare
/// a new MapViewCamera on a scene, to cache the camera state, etc.
public struct MapViewPort: Hashable, Equatable {
    
    /// The current center coordinate of the MapView
    public let center: CLLocationCoordinate2D
    
    /// The current zoom value of the MapView
    public let zoom: Double
    
    /// The current compass direction of the MapView
    public let direction: CLLocationDirection
    
    public init(center: CLLocationCoordinate2D, zoom: Double, direction: CLLocationDirection) {
        self.center = center
        self.zoom = zoom
        self.direction = direction
    }
    
    public static func zero(zoom: Double = 10) -> MapViewPort {
        return MapViewPort(center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                           zoom: zoom,
                           direction: 0)
    }
}

extension MapViewPort {
    
    /// Generate a basic MapViewCamera that represents the MapViewPort
    ///
    /// - Returns: The calculated MapViewCamera
    public func asMapViewCamera() -> MapViewCamera {
        return .center(center,
                       zoom: zoom,
                       direction: direction)
    }
}
