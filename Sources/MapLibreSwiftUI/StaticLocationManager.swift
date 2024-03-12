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
/// This class does not ever perform any authorization checks. That is the responsiblity of the caller.
public class StaticLocationManager: NSObject {
    public var delegate: (any MLNLocationManagerDelegate)? = nil {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.locationManagerDidChangeAuthorization(self)
                self.delegate?.locationManager(self, didUpdate: [self.lastLocation])
            }
        }
    }

    public var authorizationStatus: CLAuthorizationStatus = .authorizedAlways {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.locationManagerDidChangeAuthorization(self)
            }
        }
    }

    public var headingOrientation: CLDeviceOrientation = .portrait

    public var lastLocation: CLLocation {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.locationManager(self, didUpdate: [self.lastLocation])
            }
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
        // Do nothing
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
