import CoreLocation
import Foundation
import MapLibre
import Mockable

// NOTE: We should eventually mark the entire protocol @MainActor, but Mockable generates some unsafe code at the moment
@Mockable
public protocol MLNMapViewCameraUpdating: AnyObject {
    @MainActor var userTrackingMode: MLNUserTrackingMode { get set }
    @MainActor func setUserTrackingMode(_ mode: MLNUserTrackingMode, animated: Bool, completionHandler: (() -> Void)?)

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
    @MainActor func setVisibleCoordinateBounds(
        _ bounds: MLNCoordinateBounds,
        edgePadding: UIEdgeInsets,
        animated: Bool,
        completionHandler: (() -> Void)?
    )

    var activityIdentifier: String { get }
}

extension MLNMapView: MLNMapViewCameraUpdating {
    public var activityIdentifier: String {
        MapActivity.loggingValue(tag)
    }
}
