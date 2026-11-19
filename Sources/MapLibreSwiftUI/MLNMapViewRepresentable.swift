import CoreLocation
import Foundation
import MapLibre
#if MapLibreDeveloper
    import Mockable
#endif

// NOTE: We should eventually mark the entire protocol @MainActor, but Mockable generates some unsafe code at the moment

#if MapLibreDeveloper
    @Mockable
#endif
/// A representation of the MLNMapView.
///
/// This is primarily used to abstract the MLNMapView for testing.
public protocol MLNMapViewRepresentable: AnyObject {
    @MainActor var userTrackingMode: MLNUserTrackingMode { get set }
    @MainActor func setUserTrackingMode(_ mode: MLNUserTrackingMode, animated: Bool, completionHandler: (() -> Void)?)

    @MainActor var centerCoordinate: CLLocationCoordinate2D { get set }
    @MainActor var zoomLevel: Double { get set }
    @MainActor var minimumPitch: CGFloat { get set }
    @MainActor var maximumPitch: CGFloat { get set }
    @MainActor var direction: CLLocationDirection { get set }
    @MainActor var camera: MLNMapCamera { get set }
    @MainActor var frame: CGRect { get set }
    @MainActor func setCamera(_ camera: MLNMapCamera, animated: Bool)
    @MainActor func setCenter(_ coordinate: CLLocationCoordinate2D,
                              zoomLevel: Double,
                              direction: CLLocationDirection,
                              animated: Bool)
    @MainActor func setZoomLevel(_ zoomLevel: Double, animated: Bool)
    @MainActor func cameraThatFitsShape(
        _ shape: MLNShape,
        direction: CLLocationDirection,
        edgePadding: UIEdgeInsets
    ) -> MLNMapCamera
    @MainActor func setVisibleCoordinateBounds(
        _ bounds: MLNCoordinateBounds,
        edgePadding: UIEdgeInsets,
        animated: Bool,
        completionHandler: (() -> Void)?
    )
    @MainActor var visibleCoordinateBounds: MLNCoordinateBounds { get }
    @MainActor var contentInset: UIEdgeInsets { get }
    @MainActor func convert(_ coordinate: CLLocationCoordinate2D, toPointTo: UIView?) -> CGPoint
    @MainActor func convert(_ point: CGPoint, toCoordinateFrom: UIView?) -> CLLocationCoordinate2D
    @MainActor func visibleFeatures(
        at point: CGPoint,
        styleLayerIdentifiers: Set<String>?
    ) -> [any MLNFeature]
    @MainActor func visibleFeatures(
        in rect: CGRect,
        styleLayerIdentifiers: Set<String>?
    ) -> [any MLNFeature]
}

extension MLNMapView: MLNMapViewRepresentable {
    // No definition
}
