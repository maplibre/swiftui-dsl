import CarPlay
import Foundation
import OSLog

fileprivate let logger = Logger(subsystem: "MapLibreSwiftUI", category: "MapViewCameraOperations")

@MainActor
public extension MapViewCamera {
    // MARK: Zoom

    /// Set a new zoom for the current camera state.
    ///
    /// - Parameters:
    ///  - newZoom: The new zoom value.
    ///  - proxy: An optional map view proxy, this allows the camera to convert from .rect/.showcase to centered. Allowing zoom from the user's current viewport.
    mutating func setZoom(_ newZoom: Double, proxy: MapViewProxy? = nil) {
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
        case .rect, .showcase:
            // This method requires the proxy.
            guard let proxy else {
                logger.debug("Cannot setZoom on a .rect or .showcase camera without a proxy")
                return
            }
            
            state = .centered(onCoordinate: proxy.centerCoordinate,
                              zoom: newZoom,
                              pitch: MapViewCamera.Defaults.pitch,
                              pitchRange: .free,
                              direction: proxy.direction)
        }

        lastReasonForChange = .programmatic
    }

    /// Increment the zoom of the current camera state.
    ///
    /// - Parameters:
    ///   - newZoom: The value to increment the zoom by. Negative decrements the value.
    ///   - proxy: An optional map view proxy, this allows the camera to convert from .rect/.showcase to centered. Allowing zoom from the user's current viewport.
    mutating func incrementZoom(by increment: Double, proxy: MapViewProxy? = nil) {
        switch state {
        case let .centered(onCoordinate, zoom, pitch, pitchRange, direction):
            state = .centered(onCoordinate: onCoordinate,
                              zoom: zoom + increment,
                              pitch: pitch,
                              pitchRange: pitchRange,
                              direction: direction)
        case let .trackingUserLocation(zoom, pitch, pitchRange, direction):
            state = .trackingUserLocation(
                zoom: zoom + increment,
                pitch: pitch,
                pitchRange: pitchRange,
                direction: direction
            )
        case let .trackingUserLocationWithHeading(zoom, pitch, pitchRange):
            state = .trackingUserLocationWithHeading(zoom: zoom + increment, pitch: pitch, pitchRange: pitchRange)
        case let .trackingUserLocationWithCourse(zoom, pitch, pitchRange):
            state = .trackingUserLocationWithCourse(zoom: zoom + increment, pitch: pitch, pitchRange: pitchRange)
        case .rect, .showcase:
            // This method requires the proxy.
            guard let proxy else {
                logger.debug("Cannot incrementZoom on a .rect or .showcase camera without a proxy")
                return
            }
            
            state = .centered(onCoordinate: proxy.centerCoordinate,
                              zoom: proxy.zoomLevel + increment,
                              pitch: MapViewCamera.Defaults.pitch,
                              pitchRange: .free,
                              direction: proxy.direction)
        }

        lastReasonForChange = .programmatic
    }

    // MARK: Pitch

    /// Set a new pitch for the current camera state.
    ///
    /// - Parameters:
    ///   - newPitch: The new pitch value.
    ///   - proxy: An optional map view proxy, this allows the camera to convert from .rect/.showcase to centered. Allowing zoom from the user's current viewport.
    mutating func setPitch(_ newPitch: Double, proxy: MapViewProxy? = nil) {
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
        case .rect, .showcase:
            // This method requires the proxy.
            guard let proxy else {
                logger.debug("Cannot setPitch on a .rect or .showcase camera without a proxy")
                return
            }
            
            state = .centered(onCoordinate: proxy.centerCoordinate,
                              zoom: proxy.zoomLevel,
                              pitch: newPitch,
                              pitchRange: .free,
                              direction: proxy.direction)
        }

        lastReasonForChange = .programmatic
    }
    
    /// Set the direction of the camera.
    ///
    /// This will convert a rect and showcase camera to a centered camera while rotating.
    /// Tracking user location with heading and course will ignore this behavior.
    ///
    /// - Parameters:
    ///   - newDirection: The new camera direction (0 - North to 360)
    ///   - proxy: An optional map view proxy, this allows the camera to convert from .rect/.showcase to centered. Allowing zoom from the user's current viewport.
    mutating func setDirection(_ newDirection: Double, proxy: MapViewProxy? = nil) {
        switch state {
            
        case .centered(onCoordinate: let onCoordinate, zoom: let zoom, pitch: let pitch, pitchRange: let pitchRange, _):
            state = .centered(onCoordinate: onCoordinate, zoom: zoom, pitch: pitch, pitchRange: pitchRange, direction: newDirection)
        case .trackingUserLocation(zoom: let zoom, pitch: let pitch, pitchRange: let pitchRange, _):
            state = .trackingUserLocation(zoom: zoom, pitch: pitch, pitchRange: pitchRange, direction: newDirection)
        case .trackingUserLocationWithHeading:
            logger.debug("Cannot setPitch while .trackingUserLocationWithHeading")
            break
        case .trackingUserLocationWithCourse:
            logger.debug("Cannot setPitch while .trackingUserLocationWithCourse")
            break
        case .rect, .showcase:
            // This method requires the proxy.
            guard let proxy else {
                logger.debug("Cannot setDirection on a .rect or .showcase camera without a proxy")
                return
            }
            
            state = .centered(onCoordinate: proxy.centerCoordinate,
                              zoom: proxy.zoomLevel,
                              pitch: MapViewCamera.Defaults.pitch,
                              pitchRange: .free,
                              direction: newDirection)
        }
        
        lastReasonForChange = .programmatic
    }
    
    // MARK: Car Play
    
    /// Pans the camera for a CarPlay view.
    ///
    /// - Parameters:
    ///   - newPitch: The new pitch value.
    ///   - proxy: An optional map view proxy, this allows the camera to convert from .rect/.showcase to centered. Allowing zoom from the user's current viewport.
    mutating func pan(_ direction: CPMapTemplate.PanDirection, proxy: MapViewProxy? = nil) {
        var currentZoom: Double?
        var currentCenter: CLLocationCoordinate2D?
        
        switch state {
            
        case .centered(onCoordinate: let onCoordinate, zoom: let zoom, _, _, _):
            currentZoom = zoom
            currentCenter = onCoordinate
        case .trackingUserLocation(zoom: let zoom, _, _, _),
             .trackingUserLocationWithHeading(zoom: let zoom, _, _),
             .trackingUserLocationWithCourse(zoom: let zoom, _, _):
            currentZoom = zoom
        case .rect, .showcase:
            break
        }
        
        let zoom = currentZoom ?? proxy?.zoomLevel ?? MapViewCamera.Defaults.zoom
        let center = currentCenter ?? proxy?.centerCoordinate ?? MapViewCamera.Defaults.coordinate
        
        // Adjust +5 for desired sensitivity
        let sensitivity: Double = 5
        // Pan distance decreases exponentially with zoom level
        // At zoom 0: ~5.6 degrees, at zoom 10: ~0.0055 degrees, at zoom 20: ~0.000005 degrees
        let basePanDistance = 360.0 / pow(2, zoom + sensitivity)
        let latitudeDelta = basePanDistance
        let longitudeDelta = basePanDistance / cos(center.latitude * .pi / 180)
        
        let newCenter: CLLocationCoordinate2D? = switch direction {
        case .down:
            CLLocationCoordinate2D(latitude: center.latitude - latitudeDelta, longitude: center.longitude)
        case .up:
            CLLocationCoordinate2D(latitude: center.latitude + latitudeDelta, longitude: center.longitude)
        case .left:
            CLLocationCoordinate2D(latitude: center.latitude, longitude: center.longitude - longitudeDelta)
        case .right:
            CLLocationCoordinate2D(latitude: center.latitude, longitude: center.longitude + longitudeDelta)
        default:
            nil
        }
        
        guard let newCenter else {
            return
        }
        
        self = .center(newCenter, zoom: zoom)
        lastReasonForChange = .programmatic
    }
}
