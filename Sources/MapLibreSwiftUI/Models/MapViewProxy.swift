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

    public var visibleCoordinateBounds: MLNCoordinateBounds {
        mapView.visibleCoordinateBounds
    }

    public var mapViewSize: CGSize {
        mapView.frame.size
    }

    public var contentInset: UIEdgeInsets {
        mapView.contentInset
    }

    /// The reason the view port was changed.
    public let lastReasonForChange: CameraChangeReason?

    private let mapView: MLNMapView

    public func convert(_ coordinate: CLLocationCoordinate2D, toPointTo: UIView?) -> CGPoint {
        mapView.convert(coordinate, toPointTo: toPointTo)
    }

    public init(mapView: MLNMapView,
                lastReasonForChange: CameraChangeReason?)
    {
        self.mapView = mapView
        self.lastReasonForChange = lastReasonForChange
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
