import Foundation
import CoreLocation
import MapLibre
import Mockable

@Mockable
protocol MLNMapViewCameraUpdating: AnyObject {
    var userTrackingMode: MLNUserTrackingMode { get set }
    var minimumPitch: CGFloat { get set }
    var maximumPitch: CGFloat { get set }
    func setCenter(_ coordinate: CLLocationCoordinate2D,
                   zoomLevel: Double,
                   direction: CLLocationDirection,
                   animated: Bool)
    func setZoomLevel(_ zoomLevel: Double, animated: Bool)
	func setVisibleCoordinateBounds(_ bounds: MLNCoordinateBounds, edgePadding: UIEdgeInsets, animated: Bool, completionHandler: (() -> Void)?)
}

extension MLNMapView: MLNMapViewCameraUpdating {
    // No definition
}
