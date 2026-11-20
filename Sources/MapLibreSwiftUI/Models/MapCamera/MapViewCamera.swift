import CoreLocation
import Foundation
import MapLibre

/// The SwiftUI MapViewCamera.
///
/// This manages the camera state within the MapView.
public struct MapViewCamera: Hashable, Equatable, Sendable, CustomStringConvertible {
    public enum Defaults {
        public static let coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        public static let zoom: Double = 10
        public static let pitch: Double = 0
        public static let pitchRange: CameraPitchRange = .free
        public static let direction: CLLocationDirection = 0
    }

    public var state: CameraState

    /// The reason the camera was changed.
    ///
    /// This can be used to see if the camera programmatically moved,
    /// or manipulated through a user gesture.
    public var lastReasonForChange: CameraChangeReason?

    /// Whether programmatic changes use MapLibre Native's standard camera animation.
    ///
    /// Defaults to `true`. Set this to `false` to jump immediately to a new viewport.
    /// Initial positioning is always immediate. Changing only this preference does not move the map.
    /// For tracking cameras, this controls entry into tracking; subsequent location updates use Native's behavior.
    /// SwiftUI's `withAnimation`, `.animation`, and transactions do not control the camera's timing or curve.
    public var animated: Bool = true

    /// A camera centered at 0.0, 0.0. This is typically used as a backup,
    /// pre-load for an expected camera update (e.g. before a location provider produces
    /// it's first location).
    ///
    /// - Parameter animated: Whether changes use Native's standard camera animation. Defaults to `true`.
    /// - Returns: The constructed MapViewCamera.
    public static func `default`(animated: Bool = true) -> MapViewCamera {
        MapViewCamera(
            state: .centered(
                onCoordinate: Defaults.coordinate,
                zoom: Defaults.zoom,
                pitch: Defaults.pitch,
                pitchRange: Defaults.pitchRange,
                direction: Defaults.direction
            ),
            lastReasonForChange: .programmatic,
            animated: animated
        )
    }

    /// Center the map on a specific location.
    ///
    /// - Parameters:
    ///   - coordinate: The coordinate to center the map on.
    ///   - zoom: The zoom level.
    ///   - pitch: Set the camera pitch method.
    ///   - direction: The course. Default is 0 (North).
    ///   - animated: Whether changes use Native's standard camera animation. Defaults to `true`.
    /// - Returns: The constructed MapViewCamera.
    public static func center(_ coordinate: CLLocationCoordinate2D,
                              zoom: Double,
                              pitch: Double = Defaults.pitch,
                              pitchRange: CameraPitchRange = Defaults.pitchRange,
                              direction: CLLocationDirection = Defaults.direction,
                              reason: CameraChangeReason? = nil,
                              animated: Bool = true) -> MapViewCamera
    {
        MapViewCamera(
            state: .centered(
                onCoordinate: coordinate,
                zoom: zoom,
                pitch: pitch,
                pitchRange: pitchRange,
                direction: direction
            ),
            lastReasonForChange: reason,
            animated: animated
        )
    }

    /// Enables user location tracking within the MapView.
    ///
    /// This feature uses the MLNMapView's userTrackingMode = .follow
    ///
    /// - Parameters:
    ///   - zoom: Set the desired zoom. This is a one time event and the user can manipulate their zoom after unlike
    /// pitch.
    ///   - pitch: Set the camera pitch method.
    ///   - animated: Whether changes use Native's standard camera animation. Defaults to `true`.
    /// - Returns: The MapViewCamera representing the scenario
    public static func trackUserLocation(zoom: Double = Defaults.zoom,
                                         pitch: Double = Defaults.pitch,
                                         pitchRange: CameraPitchRange = Defaults.pitchRange,
                                         direction: CLLocationDirection = Defaults.direction,
                                         animated: Bool = true) -> MapViewCamera
    {
        // Coordinate is ignored when tracking user location. However, pitch and zoom are valid.
        MapViewCamera(
            state: .trackingUserLocation(zoom: zoom, pitch: pitch, pitchRange: pitchRange, direction: direction),
            lastReasonForChange: .programmatic,
            animated: animated
        )
    }

    /// Enables user location tracking within the MapView.
    ///
    /// This feature uses the MLNMapView's userTrackingMode = .followWithHeading
    ///
    /// - Parameters:
    ///   - zoom: Set the desired zoom. This is a one time event and the user can manipulate their zoom after unlike
    /// pitch.
    ///   - pitch: Set the camera pitch method.
    ///   - animated: Whether changes use Native's standard camera animation. Defaults to `true`.
    /// - Returns: The MapViewCamera representing the scenario
    public static func trackUserLocationWithHeading(
        zoom: Double = Defaults.zoom,
        pitch: Double = Defaults.pitch,
        pitchRange: CameraPitchRange = Defaults.pitchRange,
        animated: Bool = true
    ) -> MapViewCamera {
        // Coordinate is ignored when tracking user location. However, pitch and zoom are valid.
        MapViewCamera(state: .trackingUserLocationWithHeading(zoom: zoom, pitch: pitch, pitchRange: pitchRange),
                      lastReasonForChange: .programmatic,
                      animated: animated)
    }

    /// Enables user location tracking within the MapView.
    ///
    /// This feature uses the MLNMapView's userTrackingMode = .followWithCourse
    ///
    /// - Parameters:
    ///   - zoom: Set the desired zoom. This is a one time event and the user can manipulate their zoom after unlike
    /// pitch.
    ///   - pitch: Set the camera pitch method.
    ///   - animated: Whether changes use Native's standard camera animation. Defaults to `true`.
    /// - Returns: The MapViewCamera representing the scenario
    public static func trackUserLocationWithCourse(
        zoom: Double = Defaults.zoom,
        pitch: Double = Defaults.pitch,
        pitchRange: CameraPitchRange = Defaults.pitchRange,
        animated: Bool = true
    ) -> MapViewCamera {
        // Coordinate is ignored when tracking user location. However, pitch and zoom are valid.
        MapViewCamera(state: .trackingUserLocationWithCourse(zoom: zoom, pitch: pitch, pitchRange: pitchRange),
                      lastReasonForChange: .programmatic,
                      animated: animated)
    }

    /// Positions the camera to show a specific region in the MapView.
    ///
    /// - Parameters:
    ///   - box: Set the desired bounding box. This is a one time event and the user can manipulate by moving the map.
    ///   - edgePadding: Set the edge insets that should be applied before positioning the map.
    ///   - animated: Whether changes use Native's standard camera animation. Defaults to `true`.
    /// - Returns: The MapViewCamera representing the scenario
    public static func boundingBox(
        _ box: MLNCoordinateBounds,
        edgePadding: UIEdgeInsets = .init(top: 20, left: 20, bottom: 20, right: 20),
        animated: Bool = true
    ) -> MapViewCamera {
        MapViewCamera(state: .rect(boundingBox: box, edgePadding: edgePadding),
                      lastReasonForChange: .programmatic,
                      animated: animated)
    }

    /// Positions the camera to showcase a collection of shapes in the MapView.
    ///
    /// - Parameters:
    ///   - shapeCollection: The shapes that should be visible.
    ///   - edgePadding: The edge insets that should be applied before fitting the camera.
    ///   - animated: Whether changes use Native's standard camera animation. Defaults to `true`.
    /// - Returns: The MapViewCamera representing the scenario.
    public static func showcase(
        shapeCollection: MLNShapeCollection,
        edgePadding: UIEdgeInsets = .init(top: 20, left: 20, bottom: 20, right: 20),
        animated: Bool = true
    ) -> MapViewCamera {
        MapViewCamera(
            state: .showcase(shapeCollection: shapeCollection, edgePadding: edgePadding),
            lastReasonForChange: .programmatic,
            animated: animated
        )
    }

    public var description: String {
        "State: \(state) last: \((lastReasonForChange != nil) ? "\(lastReasonForChange!)" : "nil")"
    }
}
