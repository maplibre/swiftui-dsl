import Foundation
import MapLibre

/// The CameraState is used to understand the current context of the MapView's camera.
public enum CameraState {
    
    /// Centered on a coordinate
    case centered
    
    /// The camera is currently following a location provider.
    case trackingUserLocation
    
    /// Centered on a bounding box/rectangle.
    case rect
    
    /// Showcasing a GeoJSON/Polygon
    case showcase
}

extension CameraState: Equatable {
    
    public static func ==(lhs: CameraState, rhs: CameraState) -> Bool {
        switch (lhs, rhs) {
            
        case (.centered, .centered):
            return true
        case (.trackingUserLocation, .trackingUserLocation):
            return true
        case (.rect, .rect):
            return true
        case (.showcase, .showcase):
            return true
        default:
            return false
        }
    }
}
