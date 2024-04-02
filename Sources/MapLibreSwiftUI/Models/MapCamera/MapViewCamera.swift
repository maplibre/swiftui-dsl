import CoreLocation
import Foundation
import MapLibre

/// The SwiftUI MapViewCamera.
///
/// This manages the camera state within the MapView.
public struct MapViewCamera: Hashable {
    public enum Defaults {
        public static let coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        public static let zoom: Double = 10
        public static let pitch: CameraPitch = .free
        public static let direction: CLLocationDirection = 0
    }

    public var state: CameraState

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
        MapViewCamera(
            state: .centered(
                onCoordinate: Defaults.coordinate,
                zoom: Defaults.zoom,
                pitch: Defaults.pitch,
                direction: Defaults.direction
            ),
            lastReasonForChange: .programmatic
        )
    }

    /// Center the map on a specific location.
    ///
    /// - Parameters:
    ///   - coordinate: The coordinate to center the map on.
    ///   - zoom: The zoom level.
    ///   - pitch: Set the camera pitch method.
    ///   - direction: The course. Default is 0 (North).
    /// - Returns: The constructed MapViewCamera.
    public static func center(_ coordinate: CLLocationCoordinate2D,
                              zoom: Double,
                              pitch: CameraPitch = Defaults.pitch,
                              direction: CLLocationDirection = Defaults.direction,
                              reason: CameraChangeReason? = nil) -> MapViewCamera
    {
        MapViewCamera(state: .centered(onCoordinate: coordinate, zoom: zoom, pitch: pitch, direction: direction),
                      lastReasonForChange: reason)
    }

    /// Enables user location tracking within the MapView.
    ///
    /// This feature uses the MLNMapView's userTrackingMode = .follow
    ///
    /// - Parameters:
    ///   - zoom: Set the desired zoom. This is a one time event and the user can manipulate their zoom after unlike
    /// pitch.
    ///   - pitch: Set the camera pitch method.
    /// - Returns: The MapViewCamera representing the scenario
    public static func trackUserLocation(zoom: Double = Defaults.zoom,
                                         pitch: CameraPitch = Defaults.pitch,
                                         direction: CLLocationDirection = Defaults.direction) -> MapViewCamera
    {
        // Coordinate is ignored when tracking user location. However, pitch and zoom are valid.
        MapViewCamera(state: .trackingUserLocation(zoom: zoom, pitch: pitch, direction: direction),
                      lastReasonForChange: .programmatic)
    }

    /// Enables user location tracking within the MapView.
    ///
    /// This feature uses the MLNMapView's userTrackingMode = .followWithHeading
    ///
    /// - Parameters:
    ///   - zoom: Set the desired zoom. This is a one time event and the user can manipulate their zoom after unlike
    /// pitch.
    ///   - pitch: Set the camera pitch method.
    /// - Returns: The MapViewCamera representing the scenario
    public static func trackUserLocationWithHeading(zoom: Double = Defaults.zoom,
                                                    pitch: CameraPitch = Defaults.pitch) -> MapViewCamera
    {
        // Coordinate is ignored when tracking user location. However, pitch and zoom are valid.
        MapViewCamera(state: .trackingUserLocationWithHeading(zoom: zoom, pitch: pitch),
                      lastReasonForChange: .programmatic)
    }

    /// Enables user location tracking within the MapView.
    ///
    /// This feature uses the MLNMapView's userTrackingMode = .followWithCourse
    ///
    /// - Parameters:
    ///   - zoom: Set the desired zoom. This is a one time event and the user can manipulate their zoom after unlike
    /// pitch.
    ///   - pitch: Set the camera pitch method.
    /// - Returns: The MapViewCamera representing the scenario
    public static func trackUserLocationWithCourse(zoom: Double = Defaults.zoom,
                                                   pitch: CameraPitch = Defaults.pitch) -> MapViewCamera
    {
        // Coordinate is ignored when tracking user location. However, pitch and zoom are valid.
        MapViewCamera(state: .trackingUserLocationWithCourse(zoom: zoom, pitch: pitch),
                      lastReasonForChange: .programmatic)
    }

    /// Positions the camera to show a specific region in the MapView.
    ///
    /// - Parameters:
    ///   - box: Set the desired bounding box. This is a one time event and the user can manipulate by moving the map.
    ///   - edgePadding: Set the edge insets that should be applied before positioning the map.
    /// - Returns: The MapViewCamera representing the scenario
    public static func boundingBox(
        _ box: MLNCoordinateBounds,
        edgePadding: UIEdgeInsets = .init(top: 20, left: 20, bottom: 20, right: 20)
    ) -> MapViewCamera {
        MapViewCamera(state: .rect(boundingBox: box, edgePadding: edgePadding),
                      lastReasonForChange: .programmatic)
    }
}
