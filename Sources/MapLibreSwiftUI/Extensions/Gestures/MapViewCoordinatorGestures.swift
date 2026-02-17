import MapLibre

extension MapViewCoordinator {
    /// Syncronizes the latest gestures on the map view.
    ///
    /// - Parameters:
    ///   - mapView: The MLNMapView that will host the gesture itself.
    ///   - context: The UIViewRepresentable context that will orchestrate the response sender
    ///   - gesture: The gesture definition.
    func syncGestures(on mapView: MLNMapView, gestures: [MapGesture]) {
        removeAllGestures(mapView)
        addGestures(to: mapView, gestures: gestures)
    }

    /// Add an array of gestures to a map view.
    ///
    /// - Parameters:
    ///   - mapView: The MapLibre map view to apply gestures to. This is hosted by ``MapView`` and the coordinator.
    ///   - gestures: The array of map gestures to add to the map.
    func addGestures(to mapView: MLNMapView, gestures: [MapGesture]) {
        for gesture in gestures {
            switch gesture.method {
            case .tap:
                addTapGesture(to: mapView, gesture: gesture)
            case .longPress:
                addLongPressGesture(to: mapView, gesture: gesture)
            }
        }
    }

    /// Remove/clean up all gesture recognizers that were applied.
    ///
    /// - Parameter mapView: The MapLibre map view
    private func removeAllGestures(_ mapView: MLNMapView) {
        mapView.gestureRecognizers?.forEach { gestureRecognizer in
            mapView.removeGestureRecognizer(gestureRecognizer)
        }
    }

    // MARK: Individual Gesture Tools

    private func addTapGesture(to mapView: MLNMapView, gesture: MapGesture) {
        guard case let .tap(numberOfTaps: numberOfTaps) = gesture.method else {
            return
        }

        let gestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(captureGesture(_:))
        )
        gestureRecognizer.numberOfTapsRequired = numberOfTaps

        if numberOfTaps == 1 {
            // If a user double taps to zoom via the built in gesture, a normal
            // tap should not be triggered.
            if let doubleTapRecognizer = mapView.gestureRecognizers?
                .first(where: {
                    $0 is UITapGestureRecognizer && ($0 as! UITapGestureRecognizer).numberOfTapsRequired == 2
                })
            {
                gestureRecognizer.require(toFail: doubleTapRecognizer)
            }
        }
        mapView.addGestureRecognizer(gestureRecognizer)
        gesture.gestureRecognizer = gestureRecognizer
    }

    func addLongPressGesture(to mapView: MLNMapView, gesture: MapGesture) {
        guard case let .longPress(minimumDuration: minimumDuration) = gesture.method else {
            return
        }

        let gestureRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(captureGesture(_:))
        )
        gestureRecognizer.minimumPressDuration = minimumDuration

        mapView.addGestureRecognizer(gestureRecognizer)
        gesture.gestureRecognizer = gestureRecognizer
    }
}
