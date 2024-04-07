import Foundation

public extension MapViewCamera {
    // MARK: Zoom

    /// Set a new zoom for the current camera state.
    ///
    /// - Parameter newZoom: The new zoom value.
    mutating func setZoom(_ newZoom: Double) {
        switch state {
        case let .centered(onCoordinate, _, pitch, direction):
            state = .centered(onCoordinate: onCoordinate,
                              zoom: newZoom,
                              pitch: pitch,
                              direction: direction)
        case let .trackingUserLocation(_, pitch, direction):
            state = .trackingUserLocation(zoom: newZoom, pitch: pitch, direction: direction)
        case let .trackingUserLocationWithHeading(_, pitch):
            state = .trackingUserLocationWithHeading(zoom: newZoom, pitch: pitch)
        case let .trackingUserLocationWithCourse(_, pitch):
            state = .trackingUserLocationWithCourse(zoom: newZoom, pitch: pitch)
        case .rect(_, _):
            return
        case .showcase(_):
            return
        }

        lastReasonForChange = .programmatic
    }

    /// Increment the zoom of the current camera state.
    ///
    /// - Parameter newZoom: The value to increment the zoom by. Negative decrements the value.
    mutating func incrementZoom(by increment: Double) {
        switch state {
        case let .centered(onCoordinate, zoom, pitch, direction):
            state = .centered(onCoordinate: onCoordinate,
                              zoom: zoom + increment,
                              pitch: pitch,
                              direction: direction)
        case let .trackingUserLocation(zoom, pitch, direction):
            state = .trackingUserLocation(zoom: zoom + increment, pitch: pitch, direction: direction)
        case let .trackingUserLocationWithHeading(zoom, pitch):
            state = .trackingUserLocationWithHeading(zoom: zoom + increment, pitch: pitch)
        case let .trackingUserLocationWithCourse(zoom, pitch):
            state = .trackingUserLocationWithCourse(zoom: zoom + increment, pitch: pitch)
        case .rect(_, _):
            return
        case .showcase(_):
            return
        }

        lastReasonForChange = .programmatic
    }

    // MARK: Pitch

    /// Set a new pitch for the current camera state.
    ///
    /// - Parameter newPitch: The new pitch value.
    mutating func setPitch(_ newPitch: CameraPitch) {
        switch state {
        case let .centered(onCoordinate, zoom, _, direction):
            state = .centered(onCoordinate: onCoordinate,
                              zoom: zoom,
                              pitch: newPitch,
                              direction: direction)
        case let .trackingUserLocation(zoom, _, direction):
            state = .trackingUserLocation(zoom: zoom, pitch: newPitch, direction: direction)
        case let .trackingUserLocationWithHeading(zoom, _):
            state = .trackingUserLocationWithHeading(zoom: zoom, pitch: newPitch)
        case let .trackingUserLocationWithCourse(zoom, _):
            state = .trackingUserLocationWithCourse(zoom: zoom, pitch: newPitch)
        case .rect(_, _):
            return
        case .showcase(_):
            return
        }

        lastReasonForChange = .programmatic
    }

    // TODO: Add direction set
}
