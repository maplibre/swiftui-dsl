import Foundation
import CoreLocation

public struct MapViewCamera {
    
    public var state: CameraState
    public var coordinate: CLLocationCoordinate2D
    public var zoom: Double
    public var pitch: Double
    public var course: CLLocationDirection
    
    /// A camera centered at 0.0, 0.0. This is typically used as a backup,
    /// pre-load for an expected camera update (e.g. before a location provider produces
    /// it's first location).
    ///
    /// - Returns: The constructed MapViewCamera.
    public static func `default`() -> MapViewCamera {
        return MapViewCamera(state: .centered,
                             coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                             zoom: 10,
                             pitch: 90,
                             course: 0)
    }
    
    /// Center the map on a specific location.
    ///
    /// - Parameters:
    ///   - coordinate: The coordinate to center the map on.
    ///   - zoom: The zoom level.
    ///   - pitch: The camera pitch. Default is 90 (straight down).
    ///   - course: The course. Default is 0 (North).
    /// - Returns: The constructed MapViewCamera.
    public static func center(_ coordinate: CLLocationCoordinate2D,
                              zoom: Double,
                              pitch: Double = 90.0,
                              course: Double = 0) -> MapViewCamera {
        
        return MapViewCamera(state: .centered,
                             coordinate: coordinate,
                             zoom: zoom,
                             pitch: pitch,
                             course: course)
    }
    
    public static func trackUserLocation(_ location: CLLocation,
                                         zoom: Double,
                                         pitch: Double = 90.0) -> MapViewCamera {
        
        return MapViewCamera(state: .trackingUserLocation,
                             coordinate: location.coordinate,
                             zoom: zoom,
                             pitch: pitch,
                             course: location.course)
    }
    
    // TODO: Create init methods for other camera states once supporting materials are understood (e.g. BoundingBox)
}

extension MapViewCamera: Equatable {
    
    public static func ==(lhs: MapViewCamera, rhs: MapViewCamera) -> Bool {
        return lhs.state == rhs.state
            && lhs.coordinate.latitude == rhs.coordinate.latitude
            && lhs.coordinate.longitude == rhs.coordinate.longitude
            && lhs.zoom == rhs.zoom
            && lhs.pitch == rhs.pitch
            && lhs.course == rhs.course
    }
}
