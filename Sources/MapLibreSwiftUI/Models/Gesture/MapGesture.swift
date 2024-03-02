import UIKit

public class MapGesture: NSObject {
    public enum Method: Equatable {
        /// A standard tap gesture (UITapGestureRecognizer)
        ///
        /// - Parameters:
        ///   - numberOfTaps: The number of taps required for the gesture to trigger
        case tap(numberOfTaps: Int = 1)

        /// A standard long press gesture (UILongPressGestureRecognizer)
        ///
        /// - Parameters:
        ///   - minimumDuration: The minimum duration of the press in seconds.
        case longPress(minimumDuration: Double = 0.5)
    }

    /// The Gesture's method, this is used to register it for the correct user interaction on the MapView.
    let method: Method

    /// The onChange action that runs when the gesture changes on the map view.
    let onChange: (MapGestureContext) -> Void

    /// The underlying gesture recognizer
    weak var gestureRecognizer: UIGestureRecognizer?

    /// Create a new gesture recognizer definition for the MapView
    ///
    /// - Parameters:
    ///   - method: The gesture recognizer method
    ///   - onChange: The action to perform when the gesture is changed
    init(method: Method, onChange: @escaping (MapGestureContext) -> Void) {
        self.method = method
        self.onChange = onChange
    }
}
