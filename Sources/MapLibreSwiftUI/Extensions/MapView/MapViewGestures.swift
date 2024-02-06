import Foundation
import MapLibre

extension MapView {
    
    /// Register a gesture recognizer on the MapView.
    ///
    /// - Parameters:
    ///   - mapView: The MLNMapView that will host the gesture itself.
    ///   - context: The UIViewRepresentable context that will orchestrate the response sender
    ///   - gesture: The gesture definition.
    func registerGesture(_ mapView: MLNMapView, _ context: Context, gesture: MapGesture) {
        switch gesture.method {
            
        case .tap(numberOfTaps: let numberOfTaps):
            let gestureRecognizer = UITapGestureRecognizer(target: context.coordinator,
                                                           action: #selector(context.coordinator.captureGesture(_:)))
            gestureRecognizer.numberOfTapsRequired = numberOfTaps
            mapView.addGestureRecognizer(gestureRecognizer)
            gesture.gestureRecognizer = gestureRecognizer
            
        case .longPress(minimumDuration: let minimumDuration):
            let gestureRecognizer = UILongPressGestureRecognizer(target: context.coordinator,
                                                                 action: #selector(context.coordinator.captureGesture(_:)))
            gestureRecognizer.minimumPressDuration = minimumDuration
            
            mapView.addGestureRecognizer(gestureRecognizer)
            gesture.gestureRecognizer = gestureRecognizer
        }
    }
    
    /// Runs on each gesture change event and filters the appropriate gesture behavior based on the
    /// user definition.
    ///
    /// Since the gestures run "onChange", we run this every time, event when state changes. The implementer is responsible for guarding
    /// and handling whatever state logic they want.
    ///
    /// - Parameters:
    ///   - mapView: The MapView emitting the gesture. This is used to calculate the point and coordinate of the gesture.
    ///   - sender: The UIGestureRecognizer
    func processGesture(_ mapView: MLNMapView, _ sender: UIGestureRecognizer) {
        guard let gesture = self.gestures.first(where: { $0.gestureRecognizer == sender }) else {
            assertionFailure("\(sender) is not a registered UIGestureRecongizer on the MapView")
            return
        }
        
        // Build the context of the gesture's event.
        var point: CGPoint
        switch gesture.method {
            
        case .tap(numberOfTaps: let numberOfTaps):
            point = sender.location(ofTouch: numberOfTaps - 1, in: mapView)
        case .longPress:
            point = sender.location(in: mapView)
        }
        
        let context = MapGestureContext(gestureMethod: gesture.method,
                                        state: sender.state,
                                        point: point,
                                        coordinate: mapView.convert(point, toCoordinateFrom: mapView))
        
        gesture.onChange(context)
    }
}
