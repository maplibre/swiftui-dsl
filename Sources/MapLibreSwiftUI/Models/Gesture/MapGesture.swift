import Foundation

public struct MapGesture {
    
    public enum Method: Equatable {
        
        /// A standard tap gesture (UITapGestureRecognizer)
        case tap
        
        /// A standard long press gesture (UILongPressGestureRecognizer)
        case longPress
    }
    
    /// The Gesture's method, this is used to register it for the correct user interaction on the MapView.
    let method: Method
    
    /// The action that runs when the gesture is triggered from the map view.
    let action: (MapGestureContext) -> Void
}
