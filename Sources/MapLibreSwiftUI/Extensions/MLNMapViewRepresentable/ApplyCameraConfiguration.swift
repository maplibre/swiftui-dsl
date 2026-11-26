import MapLibre

@MainActor
extension MLNMapViewRepresentable {
    func apply(camera: MapViewCamera, animated: Bool) {
        switch camera.state {
        case let .centered(
            onCoordinate: coordinate,
            zoom: zoom,
            pitch: pitch,
            pitchRange: pitchRange,
            direction: direction
        ):
            userTrackingMode = .none

            // Center and pitch limit setters avoid MapLibre camera errors before layout.
            if frame.size == .zero {
                setCenter(coordinate,
                          zoomLevel: zoom,
                          direction: direction,
                          animated: animated)

                minimumPitch = pitch
                maximumPitch = pitch

                minimumPitch = pitchRange.rangeValue.lowerBound
                maximumPitch = pitchRange.rangeValue.upperBound
            } else {
                // MapLibre clamps camera transitions against the current pitch bounds.
                minimumPitch = pitchRange.rangeValue.lowerBound
                maximumPitch = pitchRange.rangeValue.upperBound

                let camera = self.camera
                camera.centerCoordinate = coordinate
                camera.heading = direction
                camera.pitch = pitch

                let altitude = MLNAltitudeForZoomLevel(zoom, pitch, coordinate.latitude, frame.size)
                camera.altitude = altitude
                setCamera(camera, animated: animated)
            }
        case let .trackingUserLocation(zoom: zoom, pitch: pitch, pitchRange: pitchRange, direction: direction):
            if frame.size == .zero {
                userTrackingMode = .follow

                zoomLevel = zoom
                self.direction = direction

                minimumPitch = pitch
                maximumPitch = pitch
                minimumPitch = pitchRange.rangeValue.lowerBound
                maximumPitch = pitchRange.rangeValue.upperBound
            } else {
                setUserTrackingMode(.follow, animated: animated) {
                    guard self.userTrackingMode == .follow else {
                        return
                    }

                    self.zoomLevel = zoom
                    self.direction = direction

                    self.minimumPitch = pitch
                    self.maximumPitch = pitch
                    self.minimumPitch = pitchRange.rangeValue.lowerBound
                    self.maximumPitch = pitchRange.rangeValue.upperBound
                }
            }
        case let .trackingUserLocationWithHeading(zoom: zoom, pitch: pitch, pitchRange: pitchRange):
            if frame.size == .zero {
                userTrackingMode = .followWithHeading

                zoomLevel = zoom

                minimumPitch = pitch
                maximumPitch = pitch
                minimumPitch = pitchRange.rangeValue.lowerBound
                maximumPitch = pitchRange.rangeValue.upperBound
            } else {
                setUserTrackingMode(.followWithHeading, animated: animated) {
                    guard self.userTrackingMode == .followWithHeading else {
                        return
                    }

                    self.zoomLevel = zoom

                    self.minimumPitch = pitch
                    self.maximumPitch = pitch
                    self.minimumPitch = pitchRange.rangeValue.lowerBound
                    self.maximumPitch = pitchRange.rangeValue.upperBound
                }
            }
        case let .trackingUserLocationWithCourse(zoom: zoom, pitch: pitch, pitchRange: pitchRange):
            if frame.size == .zero {
                userTrackingMode = .followWithCourse

                zoomLevel = zoom

                minimumPitch = pitch
                maximumPitch = pitch
                minimumPitch = pitchRange.rangeValue.lowerBound
                maximumPitch = pitchRange.rangeValue.upperBound
            } else {
                setUserTrackingMode(.followWithCourse, animated: animated) {
                    guard self.userTrackingMode == .followWithCourse else {
                        return
                    }

                    self.zoomLevel = zoom

                    self.minimumPitch = pitch
                    self.maximumPitch = pitch
                    self.minimumPitch = pitchRange.rangeValue.lowerBound
                    self.maximumPitch = pitchRange.rangeValue.upperBound
                }
            }
        case let .rect(boundingBox, padding):
            minimumPitch = 0
            maximumPitch = 0
            direction = 0

            setVisibleCoordinateBounds(boundingBox,
                                       edgePadding: padding,
                                       animated: animated,
                                       completionHandler: nil)
        case let .showcase(shapeCollection, padding):
            userTrackingMode = .none
            minimumPitch = 0
            maximumPitch = 0
            direction = 0

            let camera = cameraThatFitsShape(
                shapeCollection,
                direction: 0,
                edgePadding: padding
            )
            setCamera(camera, animated: animated)
        }
    }
}
