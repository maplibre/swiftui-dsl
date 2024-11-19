import Foundation
import MapLibre

/// The CameraState is used to understand the current context of the MapView's camera.
public enum CameraState: Hashable {
    /// Centered on a coordinate
    case centered(
        onCoordinate: CLLocationCoordinate2D,
        zoom: Double,
        pitch: Double,
        pitchRange: CameraPitchRange,
        direction: CLLocationDirection
    )

    /// Follow the user's location using the MapView's internal camera.
    ///
    /// This feature uses the MLNMapView's userTrackingMode to .follow which automatically
    /// follows the user from within the MLNMapView.
    case trackingUserLocation(zoom: Double, pitch: Double, pitchRange: CameraPitchRange, direction: CLLocationDirection)

    /// Follow the user's location using the MapView's internal camera with the user's heading.
    ///
    /// This feature uses the MLNMapView's userTrackingMode to .followWithHeading which automatically
    /// follows the user from within the MLNMapView.
    case trackingUserLocationWithHeading(zoom: Double, pitch: Double, pitchRange: CameraPitchRange)

    /// Follow the user's location using the MapView's internal camera with the users' course
    ///
    /// This feature uses the MLNMapView's userTrackingMode to .followWithCourse which automatically
    /// follows the user from within the MLNMapView.
    case trackingUserLocationWithCourse(zoom: Double, pitch: Double, pitchRange: CameraPitchRange)

    /// Centered on a bounding box/rectangle.
    case rect(
        boundingBox: MLNCoordinateBounds,
        edgePadding: UIEdgeInsets = .init(top: 20, left: 20, bottom: 20, right: 20)
    )

    /// Showcasing GeoJSON, Polygons, etc.
    case showcase(shapeCollection: MLNShapeCollection)
}

extension CameraState: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .centered(
            onCoordinate: coordinate,
            zoom: zoom,
            pitch: pitch,
            pitchRange: pitchRange,
            direction: direction
        ):
            "CameraState.centered(onCoordinate: \(coordinate), zoom: \(zoom), pitch: \(pitch), pitchRange: \(pitchRange), direction: \(direction))"
        case let .trackingUserLocation(zoom: zoom):
            "CameraState.trackingUserLocation(zoom: \(zoom))"
        case let .trackingUserLocationWithHeading(zoom: zoom):
            "CameraState.trackingUserLocationWithHeading(zoom: \(zoom))"
        case let .trackingUserLocationWithCourse(zoom: zoom):
            "CameraState.trackingUserLocationWithCourse(zoom: \(zoom))"
        case let .rect(boundingBox: boundingBox, edgePadding: edgePadding):
            "CameraState.rect(northeast: \(boundingBox.ne), southwest: \(boundingBox.sw), edgePadding: \(edgePadding))"
        case let .showcase(shapeCollection: shapeCollection):
            "CameraState.showcase(shapeCollection: \(shapeCollection))"
        }
    }
}

extension MLNCoordinateBounds: @retroactive Equatable, @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ne)
        hasher.combine(sw)
    }

    public static func == (lhs: MLNCoordinateBounds, rhs: MLNCoordinateBounds) -> Bool {
        lhs.ne == rhs.ne && lhs.sw == rhs.sw
    }
}

extension UIEdgeInsets: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(left)
        hasher.combine(right)
        hasher.combine(top)
        hasher.combine(bottom)
    }
}
