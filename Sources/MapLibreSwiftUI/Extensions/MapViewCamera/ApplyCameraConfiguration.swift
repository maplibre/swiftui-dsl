import MapLibre

@MainActor
func applyCameraConfiguration(
    _ camera: MapViewCamera,
    to mapView: MLNMapViewRepresentable,
    animated: Bool,
    isCurrent: @escaping @MainActor () -> Bool = { true }
) {
    switch camera.state {
    case let .centered(
        onCoordinate: coordinate,
        zoom: zoom,
        pitch: pitch,
        pitchRange: pitchRange,
        direction: direction
    ):
        mapView.userTrackingMode = .none

        // Center and pitch limit setters avoid MapLibre camera errors before layout.
        if mapView.frame.size == .zero {
            mapView.setCenter(coordinate,
                              zoomLevel: zoom,
                              direction: direction,
                              animated: animated)

            mapView.minimumPitch = pitch
            mapView.maximumPitch = pitch

            mapView.minimumPitch = pitchRange.rangeValue.lowerBound
            mapView.maximumPitch = pitchRange.rangeValue.upperBound
        } else {
            // MapLibre clamps camera transitions against the current pitch bounds.
            mapView.minimumPitch = pitchRange.rangeValue.lowerBound
            mapView.maximumPitch = pitchRange.rangeValue.upperBound

            let camera = mapView.camera
            camera.centerCoordinate = coordinate
            camera.heading = direction
            camera.pitch = pitch

            let altitude = MLNAltitudeForZoomLevel(zoom, pitch, coordinate.latitude, mapView.frame.size)
            camera.altitude = altitude
            mapView.setCamera(camera, animated: animated)
        }
    case let .trackingUserLocation(zoom: zoom, pitch: pitch, pitchRange: pitchRange, direction: direction):
        if mapView.frame.size == .zero {
            mapView.userTrackingMode = .follow

            mapView.zoomLevel = zoom
            mapView.direction = direction

            mapView.minimumPitch = pitch
            mapView.maximumPitch = pitch
            mapView.minimumPitch = pitchRange.rangeValue.lowerBound
            mapView.maximumPitch = pitchRange.rangeValue.upperBound
        } else {
            mapView.setUserTrackingMode(.follow, animated: animated) {
                guard isCurrent(), mapView.userTrackingMode == .follow else {
                    return
                }

                mapView.zoomLevel = zoom
                mapView.direction = direction

                mapView.minimumPitch = pitch
                mapView.maximumPitch = pitch
                mapView.minimumPitch = pitchRange.rangeValue.lowerBound
                mapView.maximumPitch = pitchRange.rangeValue.upperBound
            }
        }
    case let .trackingUserLocationWithHeading(zoom: zoom, pitch: pitch, pitchRange: pitchRange):
        if mapView.frame.size == .zero {
            mapView.userTrackingMode = .followWithHeading

            mapView.zoomLevel = zoom

            mapView.minimumPitch = pitch
            mapView.maximumPitch = pitch
            mapView.minimumPitch = pitchRange.rangeValue.lowerBound
            mapView.maximumPitch = pitchRange.rangeValue.upperBound
        } else {
            mapView.setUserTrackingMode(.followWithHeading, animated: animated) {
                guard isCurrent(), mapView.userTrackingMode == .followWithHeading else {
                    return
                }

                mapView.zoomLevel = zoom

                mapView.minimumPitch = pitch
                mapView.maximumPitch = pitch
                mapView.minimumPitch = pitchRange.rangeValue.lowerBound
                mapView.maximumPitch = pitchRange.rangeValue.upperBound
            }
        }
    case let .trackingUserLocationWithCourse(zoom: zoom, pitch: pitch, pitchRange: pitchRange):
        if mapView.frame.size == .zero {
            mapView.userTrackingMode = .followWithCourse

            mapView.zoomLevel = zoom

            mapView.minimumPitch = pitch
            mapView.maximumPitch = pitch
            mapView.minimumPitch = pitchRange.rangeValue.lowerBound
            mapView.maximumPitch = pitchRange.rangeValue.upperBound
        } else {
            mapView.setUserTrackingMode(.followWithCourse, animated: animated) {
                guard isCurrent(), mapView.userTrackingMode == .followWithCourse else {
                    return
                }

                mapView.zoomLevel = zoom

                mapView.minimumPitch = pitch
                mapView.maximumPitch = pitch
                mapView.minimumPitch = pitchRange.rangeValue.lowerBound
                mapView.maximumPitch = pitchRange.rangeValue.upperBound
            }
        }
    case let .rect(boundingBox, padding):
        mapView.minimumPitch = 0
        mapView.maximumPitch = 0
        mapView.direction = 0

        mapView.setVisibleCoordinateBounds(boundingBox,
                                           edgePadding: padding,
                                           animated: animated,
                                           completionHandler: nil)
    case let .showcase(shapeCollection, padding):
        mapView.userTrackingMode = .none
        mapView.minimumPitch = 0
        mapView.maximumPitch = 0
        mapView.direction = 0

        let camera = mapView.cameraThatFitsShape(
            shapeCollection,
            direction: 0,
            edgePadding: padding
        )
        mapView.setCamera(camera, animated: animated)
    }
}
