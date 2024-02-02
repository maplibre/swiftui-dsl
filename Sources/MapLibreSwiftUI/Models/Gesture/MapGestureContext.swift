import Foundation
import CoreLocation

public struct MapGestureContext {

    /// The map gesture that produced the context.
    public let gesture: MapGesture.Method
    
    /// The location that the gesture occured on the screen.
    public let point: CGPoint
    
    /// The underlying geographic coordinate at the point of the gesture.
    public let coordinate: CLLocationCoordinate2D
    
    /// The number of taps (of a tap gesture)
    public let numberOfTaps: Int?
}
