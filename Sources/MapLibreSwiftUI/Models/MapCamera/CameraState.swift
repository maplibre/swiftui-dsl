import Foundation
import MapLibre

/// The CameraState is used to understand the current context of the MapView's camera.
public enum CameraState: Hashable {
    
    /// Centered on a coordinate
    case coordinate(onCenter: CLLocationCoordinate2D)
    
    /// Follow the user's location using the MapView's internal camera.
    ///
    /// This feature uses the MLNMapView's userTrackingMode to .follow which automatically
    /// follows the user from within the MLNMapView.
    case trackingUserLocation
    
    /// Follow the user's location using the MapView's internal camera with the user's heading.
    ///
    /// This feature uses the MLNMapView's userTrackingMode to .followWithHeading which automatically
    /// follows the user from within the MLNMapView.
    case trackingUserLocationWithHeading
    
    /// Follow the user's location using the MapView's internal camera with the users' course
    ///
    /// This feature uses the MLNMapView's userTrackingMode to .followWithCourse which automatically
    /// follows the user from within the MLNMapView.
    case trackingUserLocationWithCourse
    
    /// Centered on a bounding box/rectangle.
    case rect(northeast: CLLocationCoordinate2D, southwest: CLLocationCoordinate2D) // TODO: make a bounding box?
    
    /// Showcasing GeoJSON, Polygons, etc.
    case showcase(shapeCollection: MLNShapeCollection)
}

extension CameraState: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
            
        case .coordinate(onCenter: let onCenter):
            return "CameraState.coordinate(onCenter: \(onCenter)"
        case .trackingUserLocation:
            return "CameraState.trackingUserLocation"
        case .trackingUserLocationWithHeading:
            return "CameraState.trackingUserLocationWithHeading"
        case .trackingUserLocationWithCourse:
            return "CameraState.trackingUserLocationWithCourse"
        case .rect(northeast: let northeast, southwest: let southwest):
            return "CameraState.rect(northeast: \(northeast), southwest: \(southwest))"
        case .showcase(shapeCollection: let shapeCollection):
            return "CameraState.showcase(shapeCollection: \(shapeCollection))"
        }
    }
}
