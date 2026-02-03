import Foundation
import MapLibre
import SwiftUI

extension MapView {
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
    @MainActor func processGesture(_ mapView: MLNMapView, _ sender: UIGestureRecognizer) {
        guard let gesture = gestureManager.gestures.first(where: { $0.gestureRecognizer == sender }) else {
            assertionFailure("\(sender) is not a registered UIGestureRecongizer on the MapView")
            return
        }

        if let clusteredLayers {
            if let gestureRecognizer = sender as? UITapGestureRecognizer, gestureRecognizer.numberOfTouches == 1 {
                let point = gestureRecognizer.location(in: sender.view)
                for clusteredLayer in clusteredLayers {
                    let features = mapView.visibleFeatures(
                        at: point,
                        styleLayerIdentifiers: [clusteredLayer.layerIdentifier]
                    )
                    if let cluster = features.first as? MLNPointFeatureCluster,
                       let source = mapView.style?
                       .source(withIdentifier: clusteredLayer.sourceIdentifier) as? MLNShapeSource
                    {
                        let zoomLevel = source.zoomLevel(forExpanding: cluster)

                        if zoomLevel > 0 {
                            mapView.setCenter(cluster.coordinate, zoomLevel: zoomLevel, animated: true)
                            break // since we can only zoom on one thing, we can abort the for loop here
                        }
                    }
                }
            }
        }

        // Process the gesture into a context response.
        let context = processContextFromGesture(mapView, gesture: gesture, sender: sender)
        // Run the context through the gesture held on the MapView (emitting to the MapView modifier).
        switch gesture.onChange {
        case let .context(action):
            action(context)
        case let .feature(action, layers):
            let point = sender.location(in: sender.view)
            let features = mapView.visibleFeatures(at: point, styleLayerIdentifiers: layers)
            action(context, features)
        }
    }

    /// Convert the sender data into a MapGestureContext
    ///
    /// - Parameters:
    ///   - mapView: The mapview that's emitting the gesture.
    ///   - gesture: The gesture definition for this event.
    ///   - sender: The UIKit gesture emitting from the map view.
    /// - Returns: The calculated context from the sending UIKit gesture
    @MainActor func processContextFromGesture(_ mapView: MLNMapView, gesture: MapGesture,
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

/// Provides the layer identifier and it's source identifier.
public struct ClusterLayer {
    public let layerIdentifier: String
    public let sourceIdentifier: String

    public init(layerIdentifier: String, sourceIdentifier: String) {
        self.layerIdentifier = layerIdentifier
        self.sourceIdentifier = sourceIdentifier
    }
}
