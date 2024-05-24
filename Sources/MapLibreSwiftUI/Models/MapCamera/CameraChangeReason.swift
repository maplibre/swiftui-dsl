import Foundation
import MapLibre

public enum CameraChangeReason: Hashable {
    case programmatic
    case resetNorth
    case gesturePan
    case gesturePinch
    case gestureRotate
    case gestureZoomIn
    case gestureZoomOut
    case gestureOneFingerZoom
    case gestureTilt
    case transitionCancelled

    /// Initialize a Swift CameraChangeReason from the MLN NSOption.
    ///
    /// This method will only show the largest bitwise reason contained in MLNCameraChangeReason.
    /// If you need a full history of the full bit range, use MLNCameraChangeReason directly
    ///
    /// - Parameter mlnCameraChangeReason: The camera change reason options list from the MapLibre MapViewDelegate
	public init?(_ mlnCameraChangeReason: MLNCameraChangeReason) {
        switch mlnCameraChangeReason.largestBitwiseReason {
        case .programmatic:
            self = .programmatic
        case .resetNorth:
            self = .resetNorth
        case .gesturePan:
            self = .gesturePan
        case .gesturePinch:
            self = .gesturePinch
        case .gestureRotate:
            self = .gestureRotate
        case .gestureZoomIn:
            self = .gestureZoomIn
        case .gestureZoomOut:
            self = .gestureZoomOut
        case .gestureOneFingerZoom:
            self = .gestureOneFingerZoom
        case .gestureTilt:
            self = .gestureTilt
        case .transitionCancelled:
            self = .transitionCancelled
        default:
            return nil
        }
    }
}
