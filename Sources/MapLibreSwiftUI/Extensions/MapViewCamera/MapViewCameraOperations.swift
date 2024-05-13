import Foundation

public extension MapViewCamera {
    // MARK: Zoom

    /// Set a new zoom for the current camera state.
    ///
    /// - Parameter newZoom: The new zoom value.
    mutating func setZoom(_ newZoom: Double) {
        switch state {
        case let .centered(onCoordinate, _, pitch, pitchRange, direction):
            state = .centered(onCoordinate: onCoordinate,
                              zoom: newZoom,
                              pitch: pitch,
                              pitchRange: pitchRange,
                              direction: direction)
        case let .trackingUserLocation(_, pitch, pitchRange, direction):
            state = .trackingUserLocation(zoom: newZoom, pitch: pitch, pitchRange: pitchRange, direction: direction)
        case let .trackingUserLocationWithHeading(_, pitch, pitchRange):
            state = .trackingUserLocationWithHeading(zoom: newZoom, pitch: pitch, pitchRange: pitchRange)
        case let .trackingUserLocationWithCourse(_, pitch, pitchRange):
            state = .trackingUserLocationWithCourse(zoom: newZoom, pitch: pitch, pitchRange: pitchRange)
        case .rect:
            return
        case .showcase:
            return
        }

        lastReasonForChange = .programmatic
    }

    /// Increment the zoom of the current camera state.
    ///
    /// - Parameter newZoom: The value to increment the zoom by. Negative decrements the value.
    mutating func incrementZoom(by increment: Double) {
        switch state {
        case let .centered(onCoordinate, zoom, pitch, pitchRange, direction):
            state = .centered(onCoordinate: onCoordinate,
                              zoom: zoom + increment,
                              pitch: pitch,
                              pitchRange: pitchRange,
                              direction: direction)
        case let .trackingUserLocation(zoom, pitch, pitchRange, direction):
            state = .trackingUserLocation(zoom: zoom + increment, pitch: pitch, pitchRange: pitchRange, direction: direction)
        case let .trackingUserLocationWithHeading(zoom, pitch, pitchRange):
            state = .trackingUserLocationWithHeading(zoom: zoom + increment, pitch: pitch, pitchRange: pitchRange)
        case let .trackingUserLocationWithCourse(zoom, pitch, pitchRange):
            state = .trackingUserLocationWithCourse(zoom: zoom + increment, pitch: pitch, pitchRange: pitchRange)
        case .rect:
            return
        case .showcase:
            return
        }

        lastReasonForChange = .programmatic
    }

    // MARK: Pitch

    /// Set a new pitch for the current camera state.
    ///
    /// - Parameter newPitch: The new pitch value.
    mutating func setPitch(_ newPitch: Double) {
        switch state {
        case let .centered(onCoordinate, zoom, _, pitchRange, direction):
            state = .centered(onCoordinate: onCoordinate,
                              zoom: zoom,
                              pitch: newPitch,
                              pitchRange: pitchRange,
                              direction: direction)
        case let .trackingUserLocation(zoom, _, pitchRange, direction):
            state = .trackingUserLocation(zoom: zoom, pitch: newPitch, pitchRange: pitchRange, direction: direction)
        case let .trackingUserLocationWithHeading(zoom, _, pitchRange):
            state = .trackingUserLocationWithHeading(zoom: zoom, pitch: newPitch, pitchRange: pitchRange)
        case let .trackingUserLocationWithCourse(zoom, _, pitchRange):
            state = .trackingUserLocationWithCourse(zoom: zoom, pitch: newPitch, pitchRange: pitchRange)
        case .rect:
            return
        case .showcase:
            return
        }

        lastReasonForChange = .programmatic
    }

    // TODO: Add direction set
}
