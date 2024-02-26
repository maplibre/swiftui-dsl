import Foundation
import MapLibre

/// The CameraState is used to understand the current context of the MapView's camera.
public enum CameraState: Hashable {
    
    /// Centered on a coordinate
    case centered(onCoordinate: CLLocationCoordinate2D)
    
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
	case rect(boundingBox: MLNCoordinateBounds, edgePadding: UIEdgeInsets = .init(top: 20, left: 20, bottom: 20, right: 20))
    
    /// Showcasing GeoJSON, Polygons, etc.
    case showcase(shapeCollection: MLNShapeCollection)
}

extension CameraState: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
            
        case .centered(onCoordinate: let onCoordinate):
            return "CameraState.centered(onCoordinate: \(onCoordinate)"
        case .trackingUserLocation:
            return "CameraState.trackingUserLocation"
        case .trackingUserLocationWithHeading:
            return "CameraState.trackingUserLocationWithHeading"
        case .trackingUserLocationWithCourse:
            return "CameraState.trackingUserLocationWithCourse"
		case .rect(boundingBox: let boundingBox, _):
			return "CameraState.rect(northeast: \(boundingBox.ne), southwest: \(boundingBox.sw))"
        case .showcase(shapeCollection: let shapeCollection):
            return "CameraState.showcase(shapeCollection: \(shapeCollection))"
        }
    }
}

extension MLNCoordinateBounds: Equatable, Hashable {
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.ne)
		hasher.combine(self.sw)
	}
	
	public static func == (lhs: MLNCoordinateBounds, rhs: MLNCoordinateBounds) -> Bool {
		return lhs.ne == rhs.ne && lhs.sw == rhs.sw
	}
}

extension UIEdgeInsets: Hashable {
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.left)
		hasher.combine(self.right)
		hasher.combine(self.top)
		hasher.combine(self.bottom)
	}
}
