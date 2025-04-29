import MapLibre

/// MapViewCamera application behaviors for the MapViewCoordinator.
extension MapViewCoordinator {

    /// Apply a camera change based on the current @State of the camera.
    ///
    /// - Parameters:
    ///   - mapView: The MapView that the state is being updated for.
    ///   - camera: The new camera state
    ///   - animated: Whether the camera change should be animated. Defaults to `true`.
    @MainActor
    func applyCameraChangeFromStateUpdate(
        _ mapView: MLNMapView,
        camera: MapViewCamera,
        animated: Bool = true
    ) {
        guard camera != snapshotCamera else {
            // No action - camera has not changed.
            return
        }
        
        snapshotCamera = camera
        
        // Cancel any existing camera update completion task.
        cameraUpdateTask?.cancel()
        cameraUpdateContinuation = nil
        
        cameraUpdateTask = Task { @MainActor in
            return await withCheckedContinuation { continuation in
                // Store the continuation to be resumed in mapViewDidBecomeIdle
                cameraUpdateContinuation = continuation

                // Apply the camera settings based on camera.state
                switch camera.state {
                case let .centered(
                    onCoordinate: coordinate,
                    zoom: zoom,
                    pitch: pitch,
                    pitchRange: pitchRange,
                    direction: direction
                ):
                    mapView.userTrackingMode = .none
        
                    if mapView.frame.size == .zero {
                        // On init, the mapView's frame is not set up yet, so manipulation via camera is broken,
                        // so let's do something else instead.
                        mapView.setCenter(coordinate,
                                          zoomLevel: zoom,
                                          direction: direction,
                                          animated: animated)
        
                        // this is a workaround for no camera - minimum and maximum will be reset below, but this adjusts it.
                        mapView.minimumPitch = pitch
                        mapView.maximumPitch = pitch
        
                    } else {
                        let camera = mapView.camera
                        camera.centerCoordinate = coordinate
                        camera.heading = direction
                        camera.pitch = pitch
        
                        let altitude = MLNAltitudeForZoomLevel(zoom, pitch, coordinate.latitude, mapView.frame.size)
                        camera.altitude = altitude
                        mapView.setCamera(camera, animated: animated)
                    }
        
                    mapView.minimumPitch = pitchRange.rangeValue.lowerBound
                    mapView.maximumPitch = pitchRange.rangeValue.upperBound
                case let .trackingUserLocation(zoom: zoom, pitch: pitch, pitchRange: pitchRange, direction: direction):
                    if mapView.frame.size == .zero {
                        // On init, the mapView's frame is not set up yet, so manipulation via camera is broken,
                        // so let's do something else instead.
                        // Needs to be non-animated or else it messes up following
        
                        mapView.userTrackingMode = .follow
        
                        mapView.setZoomLevel(zoom, animated: false)
                        mapView.direction = direction
        
                        mapView.minimumPitch = pitch
                        mapView.maximumPitch = pitch
                        mapView.minimumPitch = pitchRange.rangeValue.lowerBound
                        mapView.maximumPitch = pitchRange.rangeValue.upperBound
        
                    } else {
                        mapView.setUserTrackingMode(.follow, animated: animated) {
                            guard mapView.userTrackingMode == .follow else {
                                // Exit early if the user tracking mode is no longer set to follow
                                return
                            }
                            
                            mapView.minimumPitch = pitchRange.rangeValue.lowerBound
                            mapView.maximumPitch = pitchRange.rangeValue.upperBound
                            let camera = mapView.camera
                            camera.heading = direction
                            camera.pitch = pitch
        
                            let altitude = MLNAltitudeForZoomLevel(
                                zoom,
                                pitch,
                                mapView.camera.centerCoordinate.latitude,
                                mapView.frame.size
                            )
                            camera.altitude = altitude
                            mapView.setCamera(camera, animated: animated)
                        }
                    }
                case let .trackingUserLocationWithHeading(zoom: zoom, pitch: pitch, pitchRange: pitchRange):
                    if mapView.frame.size == .zero {
                        // On init, the mapView's frame is not set up yet, so manipulation via camera is broken,
                        // so let's do something else instead.
                        // Needs to be non-animated or else it messes up following
        
                        mapView.userTrackingMode = .followWithHeading
                        mapView.setZoomLevel(zoom, animated: false)
                        mapView.minimumPitch = pitch
                        mapView.maximumPitch = pitch
                        mapView.minimumPitch = pitchRange.rangeValue.lowerBound
                        mapView.maximumPitch = pitchRange.rangeValue.upperBound
        
                    } else {
                        mapView.setUserTrackingMode(.followWithHeading, animated: animated) {
                            guard mapView.userTrackingMode == .followWithHeading else {
                                // Exit early if the user tracking mode is no longer set to followWithHeading
                                return
                            }
                            
                            mapView.minimumPitch = pitchRange.rangeValue.lowerBound
                            mapView.maximumPitch = pitchRange.rangeValue.upperBound
                            let camera = mapView.camera
        
                            let altitude = MLNAltitudeForZoomLevel(
                                zoom,
                                pitch,
                                mapView.camera.centerCoordinate.latitude,
                                mapView.frame.size
                            )
                            camera.altitude = altitude
                            camera.pitch = pitch
                            mapView.setCamera(camera, animated: animated)
                        }
                    }
                case let .trackingUserLocationWithCourse(zoom: zoom, pitch: pitch, pitchRange: pitchRange):
                    if mapView.frame.size == .zero {
                        mapView.userTrackingMode = .followWithCourse
                        // On init, the mapView's frame is not set up yet, so manipulation via camera is broken,
                        // so let's do something else instead.
                        // Needs to be non-animated or else it messes up following
        
                        mapView.setZoomLevel(zoom, animated: false)
                        mapView.minimumPitch = pitch
                        mapView.maximumPitch = pitch
                        mapView.minimumPitch = pitchRange.rangeValue.lowerBound
                        mapView.maximumPitch = pitchRange.rangeValue.upperBound
        
                    } else {
                        mapView.setUserTrackingMode(.followWithCourse, animated: animated) {
                            guard mapView.userTrackingMode == .followWithCourse else {
                                // Exit early if the user tracking mode is no longer set to followWithCourse
                                return
                            }
                            
                            mapView.minimumPitch = pitchRange.rangeValue.lowerBound
                            mapView.maximumPitch = pitchRange.rangeValue.upperBound
        
                            let camera = mapView.camera
        
                            let altitude = MLNAltitudeForZoomLevel(
                                zoom,
                                pitch,
                                mapView.camera.centerCoordinate.latitude,
                                mapView.frame.size
                            )
                            camera.altitude = altitude
                            camera.pitch = pitch
                            mapView.setCamera(camera, animated: animated)
                        }
                    }
                case let .rect(boundingBox, padding):
                    mapView.setVisibleCoordinateBounds(boundingBox,
                                                       edgePadding: padding,
                                                       animated: animated,
                                                       completionHandler: nil)
                case .showcase:
                    // TODO: Need a method these/or to finalize a goal here.
                    break
                }
            }
        }
    }
    
    /// Apply a gesture based camera change. This behavior will only be triggered on the first gesture and will
    /// only be completed when the mapView becomes idle.
    ///
    /// - Parameters:
    ///   - mapView: The MapView that is being manipulated by a gesture.
    ///   - reason: The reason for the camera change.
    func applyCameraChangeFromGesture(_ mapView: MLNMapView, reason: CameraChangeReason) {
        guard cameraUpdateTask == nil else {
            // Gestures emit many updates, so we only want to launch the first one and rely on idle to close the event.
            return
        }
        
        cameraUpdateTask = Task { @MainActor in
            return await withCheckedContinuation { continuation in
                // Store the continuation to be resumed in mapViewDidBecomeIdle
                cameraUpdateContinuation = continuation
                
                let pitchRange: CameraPitchRange = if mapView.minimumPitch == 0 && mapView.maximumPitch > 59.9 {
                    .free
                } else if mapView.minimumPitch == mapView.maximumPitch {
                    .fixed(mapView.minimumPitch)
                } else {
                    .freeWithinRange(minimum: mapView.minimumPitch, maximum: mapView.maximumPitch)
                }
                
                parent.camera = .center(
                    mapView.centerCoordinate,
                    zoom: mapView.zoomLevel,
                    pitch: mapView.camera.pitch,
                    pitchRange: pitchRange,
                    direction: mapView.direction,
                    reason: reason)
            }
        }
    }
}
