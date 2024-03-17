import CoreLocation
import Foundation
import MapLibre
import Mockable

@Mockable
protocol MLNMapViewCameraUpdating: AnyObject {
    @MainActor var userTrackingMode: MLNUserTrackingMode { get set }
    @MainActor var minimumPitch: CGFloat { get set }
    @MainActor var maximumPitch: CGFloat { get set }
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
}

extension MLNMapView: MLNMapViewCameraUpdating {
    // No definition
}
