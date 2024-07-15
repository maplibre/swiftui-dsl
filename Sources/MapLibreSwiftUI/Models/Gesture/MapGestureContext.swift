import CoreLocation
import UIKit

/// The contextual representation of the gesture.
public struct MapGestureContext {
    /// The map gesture that produced the context.
    public let gestureMethod: MapGesture.Method

    /// The state of the on change event.
    public let state: UIGestureRecognizer.State

    /// The location that the gesture occurred on the screen.
    public let point: CGPoint

    /// The underlying geographic coordinate at the point of the gesture.
    public let coordinate: CLLocationCoordinate2D

    public init(
        gestureMethod: MapGesture.Method,
        state: UIGestureRecognizer.State,
        point: CGPoint,
        coordinate: CLLocationCoordinate2D
    ) {
        self.gestureMethod = gestureMethod
        self.state = state
        self.point = point
        self.coordinate = coordinate
    }
}
