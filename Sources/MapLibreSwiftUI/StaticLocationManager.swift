import CoreLocation
import MapLibre

/// A simple class that provides static location updates to a MapLibre view.
///
/// This is not actually driven by a location manager (such as CLLocationManager) internally, but rather by updates
/// provided one at a time. Beyond the obvious use case in testing and SwiftUI previews, this is also useful if you are
/// doing some processing of raw location data (ex: determining whether to snap locations to a road) and selectively
/// passing the updates on to the map view.
///
/// You can provide a new location by setting the ``lastLocation`` property.
///
/// This class does not ever perform any authorization checks. That is the responsibility of the caller.
public final class StaticLocationManager: NSObject, @unchecked Sendable {
    public var delegate: (any MLNLocationManagerDelegate)?

    public var authorizationStatus: CLAuthorizationStatus = .authorizedAlways {
        didSet {
            delegate?.locationManagerDidChangeAuthorization(self)
        }
    }

    // TODO: Investigate what this does and document it
    public var headingOrientation: CLDeviceOrientation = .portrait

    public var lastLocation: CLLocation {
        didSet {
            delegate?.locationManager(self, didUpdate: [lastLocation])
        }
    }

    public init(initialLocation: CLLocation) {
        lastLocation = initialLocation
    }
}

extension StaticLocationManager: MLNLocationManager {
    public func requestAlwaysAuthorization() {
        // Do nothing
    }

    public func requestWhenInUseAuthorization() {
        // Do nothing
    }

    public func startUpdatingLocation() {
        // This has to be async dispatched or else the map view will not update immediately if the camera is set to
        // follow the user's location. This leads to some REALLY (unbearably) bad artifacts. We should find a better
        // solution for this at some point. This is the reason for the @unchecked Sendable conformance by the way (so
        // that we don't get a warning about using non-sendable self; it should be safe though).
        DispatchQueue.main.async {
            self.delegate?.locationManager(self, didUpdate: [self.lastLocation])
        }
    }

    public func stopUpdatingLocation() {
        // Do nothing
    }

    public func startUpdatingHeading() {
        // Do nothing
    }

    public func stopUpdatingHeading() {
        // Do nothing
    }

    public func dismissHeadingCalibrationDisplay() {
        // Do nothing
    }
}
