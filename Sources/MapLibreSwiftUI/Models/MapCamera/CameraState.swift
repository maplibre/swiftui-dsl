import Foundation
import MapLibre

/// The CameraState is used to understand the current context of the MapView's camera.
public enum CameraState: Hashable, Codable {
    
    /// Centered on a coordinate
    case centered
    
    /// Follow the user's location using the MapView's internal camera.
    case trackingUserLocation
    
    /// Follow the user's location using the MapView's internal camera with the user's heading.
    case trackingUserLocationWithHeading
    
    /// Follow the user's location using the MapView's internal camera with the users' course
    case trackingUserLocationWithCourse
    
    /// Centered on a bounding box/rectangle.
    case rect
    
    /// Showcasing a GeoJSON/Polygon
    case showcase
}
