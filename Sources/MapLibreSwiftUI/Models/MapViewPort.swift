import CoreLocation
import Foundation

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
    
    /// The reason the view port was changed.
    public let lastReasonForChange: CameraChangeReason?

    public init(center: CLLocationCoordinate2D,
                zoom: Double,
                direction: CLLocationDirection,
                lastReasonForChange: CameraChangeReason?) {
        self.center = center
        self.zoom = zoom
        self.direction = direction
        self.lastReasonForChange = lastReasonForChange
    }

    public static func zero(zoom: Double = 10) -> MapViewPort {
        MapViewPort(center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                    zoom: zoom,
                    direction: 0,
                    lastReasonForChange: nil)
    }
}

public extension MapViewPort {
    /// Generate a basic MapViewCamera that represents the MapViewPort
    ///
    /// - Returns: The calculated MapViewCamera
    func asMapViewCamera() -> MapViewCamera {
        .center(center,
                zoom: zoom,
                direction: direction)
    }
}
