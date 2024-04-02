import Foundation

extension MapViewCamera {
    
    // MARK: Zoom
    
    /// Set a new zoom for the current camera state.
    ///
    /// - Parameter newZoom: The new zoom value.
    public mutating func setZoom(_ newZoom: Double) {
        switch self.state {
        case .centered(let onCoordinate, _, let pitch, let direction):
            self.state = .centered(onCoordinate: onCoordinate,
                                   zoom: newZoom,
                                   pitch: pitch,
                                   direction: direction)
        case .trackingUserLocation(_, let pitch, let direction):
            self.state = .trackingUserLocation(zoom: newZoom, pitch: pitch, direction: direction)
        case .trackingUserLocationWithHeading(_, let pitch):
            self.state = .trackingUserLocationWithHeading(zoom: newZoom, pitch: pitch)
        case .trackingUserLocationWithCourse(_, let pitch):
            self.state = .trackingUserLocationWithCourse(zoom: newZoom, pitch: pitch)
        case .rect(let boundingBox, let edgePadding):
            return
        case .showcase(let shapeCollection):
            return
        }
        
        self.lastReasonForChange = .programmatic
    }
    
    /// Increment the zoom of the current camera state.
    ///
    /// - Parameter newZoom: The value to increment the zoom by. Negative decrements the value.
    public mutating func incrementZoom(by increment: Double) {
        switch self.state {
        case .centered(let onCoordinate, let zoom, let pitch, let direction):
            self.state = .centered(onCoordinate: onCoordinate,
                                   zoom: zoom + increment,
                                   pitch: pitch,
                                   direction: direction)
        case .trackingUserLocation(let zoom, let pitch, let direction):
            self.state = .trackingUserLocation(zoom: zoom + increment, pitch: pitch, direction: direction)
        case .trackingUserLocationWithHeading(let zoom, let pitch):
            self.state = .trackingUserLocationWithHeading(zoom: zoom + increment, pitch: pitch)
        case .trackingUserLocationWithCourse(let zoom, let pitch):
            self.state = .trackingUserLocationWithCourse(zoom: zoom + increment, pitch: pitch)
        case .rect(let boundingBox, let edgePadding):
            return
        case .showcase(let shapeCollection):
            return
        }
        
        self.lastReasonForChange = .programmatic
    }
    
    // MARK: Pitch
    
    /// Set a new pitch for the current camera state.
    ///
    /// - Parameter newPitch: The new pitch value.
    public mutating func setPitch(_ newPitch: CameraPitch) {
        switch self.state {
        case .centered(let onCoordinate, let zoom, let pitch, let direction):
            self.state = .centered(onCoordinate: onCoordinate,
                                   zoom: zoom,
                                   pitch: newPitch,
                                   direction: direction)
        case .trackingUserLocation(let zoom, _, let direction):
            self.state = .trackingUserLocation(zoom: zoom, pitch: newPitch, direction: direction)
        case .trackingUserLocationWithHeading(let zoom, _):
            self.state = .trackingUserLocationWithHeading(zoom: zoom, pitch: newPitch)
        case .trackingUserLocationWithCourse(let zoom, _):
            self.state = .trackingUserLocationWithCourse(zoom: zoom, pitch: newPitch)
        case .rect(let boundingBox, let edgePadding):
            return
        case .showcase(let shapeCollection):
            return
        }
        
        self.lastReasonForChange = .programmatic
    }
    
    // TODO: Add direction set
    
}
