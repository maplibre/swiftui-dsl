import Foundation
import MapLibre
import SwiftUI

extension MapView {
    /// Register a gesture recognizer on the MapView.
    ///
    /// - Parameters:
    ///   - mapView: The MLNMapView that will host the gesture itself.
    ///   - context: The UIViewRepresentable context that will orchestrate the response sender
    ///   - gesture: The gesture definition.
    func registerGesture(_ mapView: MLNMapView, _ context: Context, gesture: MapGesture) {
        switch gesture.method {
        case let .tap(numberOfTaps: numberOfTaps):
            let gestureRecognizer = UITapGestureRecognizer(target: context.coordinator,
                                                           action: #selector(context.coordinator.captureGesture(_:)))
            gestureRecognizer.numberOfTapsRequired = numberOfTaps
            mapView.addGestureRecognizer(gestureRecognizer)
            gesture.gestureRecognizer = gestureRecognizer

        case let .longPress(minimumDuration: minimumDuration):
            let gestureRecognizer = UILongPressGestureRecognizer(target: context.coordinator,
                                                                 action: #selector(context.coordinator
                                                                     .captureGesture(_:)))
            gestureRecognizer.minimumPressDuration = minimumDuration

            mapView.addGestureRecognizer(gestureRecognizer)
            gesture.gestureRecognizer = gestureRecognizer
        }
    }

    /// Runs on each gesture change event and filters the appropriate gesture behavior based on the
    /// user definition.
    ///
    /// Since the gestures run "onChange", we run this every time, event when state changes. The implementer is
    /// responsible for
    /// guarding
    /// and handling whatever state logic they want.
    ///
    /// - Parameters:
    ///   - mapView: The MapView emitting the gesture. This is used to calculate the point and coordinate of the
    /// gesture.
    ///   - sender: The UIGestureRecognizer
    func processGesture(_ mapView: MLNMapView, _ sender: UIGestureRecognizer) {
        guard let gesture = gestures.first(where: { $0.gestureRecognizer == sender }) else {
            assertionFailure("\(sender) is not a registered UIGestureRecongizer on the MapView")
            return
        }

        // Process the gesture into a context response.
        let context = processContextFromGesture(mapView, gesture: gesture, sender: sender)
        // Run the context through the gesture held on the MapView (emitting to the MapView modifier).
        gesture.onChange(context)
    }

    /// Convert the sender data into a MapGestureContext
    ///
    /// - Parameters:
    ///   - mapView: The mapview that's emitting the gesture.
    ///   - gesture: The gesture definition for this event.
    ///   - sender: The UIKit gesture emitting from the map view.
    /// - Returns: The calculated context from the sending UIKit gesture
    func processContextFromGesture(_ mapView: MLNMapView, gesture: MapGesture,
                                   sender: UIGestureRecognizing) -> MapGestureContext
    {
        // Build the context of the gesture's event.
        let point: CGPoint = switch gesture.method {
        case let .tap(numberOfTaps: numberOfTaps):
            // Calculate the CGPoint of the last gesture tap
            sender.location(ofTouch: numberOfTaps - 1, in: mapView)
        case .longPress:
            // Calculate the CGPoint of the long process gesture.
            sender.location(in: mapView)
        }

        return MapGestureContext(gestureMethod: gesture.method,
                                 state: sender.state,
                                 point: point,
                                 coordinate: mapView.convert(point, toCoordinateFrom: mapView))
    }
}
