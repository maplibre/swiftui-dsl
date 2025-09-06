import CoreLocation
import Foundation
import MapLibre

/// A read only representation of the MapView's current View.
///
/// Provides access to properties and functions of the underlying MLNMapView,
/// but properties only expose their getter, and functions are only available if they
/// do no change the state of the MLNMapView. Writing directly to properties of MLNMapView
/// could clash with swiftui-dsl's state management, which is why modifiying functions
/// and properties are not exposed.
///
/// You can use `MapView.onMapViewProxyUpdate(_ onViewProxyChanged: @escaping (MapViewProxy) -> Void)` to
/// recieve access to the MapViewProxy.
///
/// For more information about the properties and functions, see
/// https://maplibre.org/maplibre-native/ios/latest/documentation/maplibre/mlnmapview
@MainActor
public struct MapViewProxy: Hashable, Equatable {
    /// The current center coordinate of the MapView
    public let centerCoordinate: CLLocationCoordinate2D

    /// The current zoom value of the MapView
    public let zoomLevel: Double

    /// The current compass direction of the MapView
    public let direction: CLLocationDirection

    /// The visible coordinate bounds of the MapView
    public let visibleCoordinateBounds: MLNCoordinateBounds

    /// The size of the MapView
    public let mapViewSize: CGSize

    /// The content inset of the MapView
    public let contentInset: UIEdgeInsets

    /// The reason the view port was changed.
    public let lastReasonForChange: CameraChangeReason?

    /// The underlying MLNMapView (only used for functions that require it)
    private let mapView: MLNMapView?

    /// Convert a coordinate to a point in the MapView
    /// - Parameters:
    ///   - coordinate: The coordinate to convert
    ///   - toPointTo: The view to convert the point to (usually nil for the MapView itself)
    /// - Returns: The CGPoint representation of the coordinate
    public func convert(_ coordinate: CLLocationCoordinate2D, toPointTo: UIView?) -> CGPoint? {
        guard let mapView else {
            return nil
        }
        return mapView.convert(coordinate, toPointTo: toPointTo)
    }

    /// Initialize with an MLNMapView (captures current values)
    /// - Parameters:
    ///   - mapView: The MLNMapView to capture values from
    ///   - lastReasonForChange: The reason for the last camera change
    public init(mapView: MLNMapView, lastReasonForChange: CameraChangeReason?) {
        self.centerCoordinate = mapView.centerCoordinate
        self.zoomLevel = mapView.zoomLevel
        self.direction = mapView.direction
        self.visibleCoordinateBounds = mapView.visibleCoordinateBounds
        self.mapViewSize = mapView.frame.size
        self.contentInset = mapView.contentInset
        self.lastReasonForChange = lastReasonForChange
        self.mapView = mapView
    }

    /// Initialize with explicit values (useful for testing)
    /// - Parameters:
    ///   - centerCoordinate: The center coordinate
    ///   - zoomLevel: The zoom level
    ///   - direction: The compass direction
    ///   - visibleCoordinateBounds: The visible coordinate bounds
    ///   - mapViewSize: The size of the map view
    ///   - contentInset: The content inset
    ///   - lastReasonForChange: The reason for the last camera change
    public init(
        centerCoordinate: CLLocationCoordinate2D,
        zoomLevel: Double,
        direction: CLLocationDirection,
        visibleCoordinateBounds: MLNCoordinateBounds,
        mapViewSize: CGSize = CGSize(width: 320, height: 568),
        contentInset: UIEdgeInsets = .zero,
        lastReasonForChange: CameraChangeReason? = nil
    ) {
        self.centerCoordinate = centerCoordinate
        self.zoomLevel = zoomLevel
        self.direction = direction
        self.visibleCoordinateBounds = visibleCoordinateBounds
        self.mapViewSize = mapViewSize
        self.contentInset = contentInset
        self.lastReasonForChange = lastReasonForChange
        self.mapView = nil
    }
}

public extension MapViewProxy {
    /// Generate a basic MapViewCamera that represents the MapView
    ///
    /// - Returns: The calculated MapViewCamera
    func asMapViewCamera() -> MapViewCamera {
        .center(centerCoordinate,
                zoom: zoomLevel,
                direction: direction)
    }
}
