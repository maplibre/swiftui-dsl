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
public struct MapViewProxy {
    /// The current center coordinate of the MapView
    public var centerCoordinate: CLLocationCoordinate2D {
        mapView.centerCoordinate
    }

    /// The current zoom value of the MapView
    public var zoomLevel: Double {
        mapView.zoomLevel
    }

    /// The current compass direction of the MapView
    public var direction: CLLocationDirection {
        mapView.direction
    }

    /// The visible coordinate bounds of the MapView
    public var visibleCoordinateBounds: MLNCoordinateBounds {
        mapView.visibleCoordinateBounds
    }

    /// The size of the MapView
    public var mapViewSize: CGSize {
        mapView.frame.size
    }

    /// The content inset of the MapView
    public var contentInset: UIEdgeInsets {
        mapView.contentInset
    }

    /// The reason the view port was changed.
    public let lastReasonForChange: CameraChangeReason?

    /// The underlying MLNMapView (only used for functions that require it)
    private let mapView: MLNMapViewRepresentable

    /// Convert a coordinate to a point in the MapView
    /// - Parameters:
    ///   - coordinate: The coordinate to convert
    ///   - toPointTo: The view to convert the point to (usually nil for the MapView itself)
    /// - Returns: The CGPoint representation of the coordinate
    public func convert(_ coordinate: CLLocationCoordinate2D, toPointTo: UIView?) -> CGPoint {
        mapView.convert(coordinate, toPointTo: toPointTo)
    }

    /// Initialize with an MLNMapView (captures current values)
    /// - Parameters:
    ///   - mapView: The MLNMapView to capture values from
    ///   - lastReasonForChange: The reason for the last camera change
    public init(mapView: MLNMapViewRepresentable, lastReasonForChange: CameraChangeReason?) {
        self.lastReasonForChange = lastReasonForChange
        self.mapView = mapView
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
