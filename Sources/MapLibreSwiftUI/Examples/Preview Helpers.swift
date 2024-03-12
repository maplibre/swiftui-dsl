// This file contains helpers that are used in the SwiftUI preview examples
import CoreLocation
import MapLibre

let switzerland = CLLocationCoordinate2D(latitude: 47.03041, longitude: 8.29470)
let demoTilesURL =
    URL(string: "https://demotiles.maplibre.org/style.json")!

/// A simple class that provides a user location to a MapLibre view.
///
/// This makes it easier to write SwiftUI previews without having to worry about location permissions.
class PreviewLocationManager: NSObject {
    var delegate: (any MLNLocationManagerDelegate)? = nil {
        didSet {
            // Necessary to trigger an initial update correctly if the camera is set on init
            DispatchQueue.main.async {
                self.delegate?.locationManagerDidChangeAuthorization(self)
                self.delegate?.locationManager(self, didUpdate: [self.lastLocation])
            }
        }
    }

    var authorizationStatus: CLAuthorizationStatus {
        CLAuthorizationStatus.authorizedAlways
    }

    var headingOrientation: CLDeviceOrientation = .portrait

    var lastLocation: CLLocation {
        didSet {
            delegate?.locationManager(self, didUpdate: [lastLocation])
        }
    }

    init(initialLocation: CLLocation) {
        lastLocation = initialLocation
    }
}

extension PreviewLocationManager: MLNLocationManager {
    func requestAlwaysAuthorization() {
        // Do nothing
    }

    func requestWhenInUseAuthorization() {
        // Do nothing
    }

    func startUpdatingLocation() {
        // Do nothing
    }

    func stopUpdatingLocation() {
        // Do nothing
    }

    func startUpdatingHeading() {
        // Do nothing
    }

    func stopUpdatingHeading() {
        // Do nothing
    }

    func dismissHeadingCalibrationDisplay() {
        // Do nothing
    }
}
