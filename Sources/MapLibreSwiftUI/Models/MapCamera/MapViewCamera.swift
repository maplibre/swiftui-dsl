import Foundation
import CoreLocation
import MapLibre

public struct MapViewCamera: Hashable {
    
    public struct Defaults {
        public static let coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        public static let zoom: Double = 10
        public static let pitch: Double? = nil
        public static let course: Double = 0
    }
    
    public var state: CameraState
    public var coordinate: CLLocationCoordinate2D
    public var zoom: Double
    public var pitch: Double?
    public var course: CLLocationDirection
    
    /// The reason the camera was changed.
    ///
    /// This can be used to see if the camera programmatically moved,
    /// or manipulated through a user gesture.
    public var lastReasonForChange: CameraChangeReason?
    
    /// A camera centered at 0.0, 0.0. This is typically used as a backup,
    /// pre-load for an expected camera update (e.g. before a location provider produces
    /// it's first location).
    ///
    /// - Returns: The constructed MapViewCamera.
    public static func `default`() -> MapViewCamera {
        return MapViewCamera(state: .centered,
                             coordinate: Defaults.coordinate,
                             zoom: Defaults.zoom,
                             pitch: Defaults.pitch,
                             course: Defaults.course,
                             lastReasonForChange: .programmatic)
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
                              pitch: Double? = Defaults.pitch,
                              course: Double = Defaults.course,
                              reason: CameraChangeReason? = nil) -> MapViewCamera {
        
        return MapViewCamera(state: .centered,
                             coordinate: coordinate,
                             zoom: zoom,
                             pitch: pitch,
                             course: course,
                             lastReasonForChange: reason)
    }
    
    /// Enables user location tracking within the MapView.
    ///
    /// This feature uses the MLNMapView's userTrackingMode = .follow
    ///
    /// - Parameters:
    ///   - zoom: Set the desired zoom. This is a one time event and the user can manipulate their zoom after unlike pitch.
    ///   - pitch: Provide a fixed pitch value. The user will not be able to adjust pitch using gestures when this is set. Use nil/default to allow user control.
    /// - Returns: The MapViewCamera representing the scenario
    public static func trackUserLocation(zoom: Double = Defaults.zoom,
                                         pitch: Double? = Defaults.pitch) -> MapViewCamera {
        
        // Coordinate is ignored when tracking user location. However, pitch and zoom are valid.
        return MapViewCamera(state: .trackingUserLocation,
                             coordinate: Defaults.coordinate,
                             zoom: zoom,
                             pitch: pitch,
                             course: Defaults.course,
                             lastReasonForChange: .programmatic)
    }
    
    /// Enables user location tracking within the MapView.
    ///
    /// This feature uses the MLNMapView's userTrackingMode = .follow
    ///
    /// - Parameters:
    ///   - zoom: Set the desired zoom. This is a one time event and the user can manipulate their zoom after unlike pitch.
    ///   - pitch: Provide a fixed pitch value. The user will not be able to adjust pitch using gestures when this is set. Use nil/default to allow user control.
    /// - Returns: The MapViewCamera representing the scenario
    public static func trackUserLocationWithHeading(zoom: Double = Defaults.zoom,
                                                    pitch: Double? = Defaults.pitch) -> MapViewCamera {
        
        // Coordinate is ignored when tracking user location. However, pitch and zoom are valid.
        return MapViewCamera(state: .trackingUserLocationWithHeading,
                             coordinate: Defaults.coordinate,
                             zoom: zoom,
                             pitch: pitch,
                             course: Defaults.course,
                             lastReasonForChange: .programmatic)
    }
    
    /// Enables user location tracking within the MapView.
    ///
    /// This feature uses the MLNMapView's userTrackingMode = .follow
    ///
    /// - Parameters:
    ///   - zoom: Set the desired zoom. This is a one time event and the user can manipulate their zoom after unlike pitch.
    ///   - pitch: Provide a fixed pitch value. The user will not be able to adjust pitch using gestures when this is set. Use nil/default to allow user control.
    /// - Returns: The MapViewCamera representing the scenario
    public static func trackUserLocationWithCourse(zoom: Double = Defaults.zoom,
                                                   pitch: Double? = Defaults.pitch) -> MapViewCamera {

        // Coordinate is ignored when tracking user location. However, pitch and zoom are valid.
        return MapViewCamera(state: .trackingUserLocationWithCourse,
                             coordinate: Defaults.coordinate,
                             zoom: zoom,
                             pitch: pitch,
                             course: Defaults.course,
                             lastReasonForChange: .programmatic)
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
            && lhs.lastReasonForChange == rhs.lastReasonForChange
    }
}
