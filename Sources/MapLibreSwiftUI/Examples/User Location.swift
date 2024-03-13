import CoreLocation
import SwiftUI

private let locationManager = StaticLocationManager(initialLocation: CLLocation(
    coordinate: switzerland,
    altitude: 0,
    horizontalAccuracy: 1,
    verticalAccuracy: 1,
    course: 8,
    speed: 28,
    timestamp: Date()
))

#Preview("Track user location") {
    MapView(
        styleURL: demoTilesURL,
        camera: .constant(.trackUserLocation(zoom: 4, pitch: .fixed(45))),
        locationManager: locationManager
    )
    .mapViewContentInset(.init(top: 450, left: 0, bottom: 0, right: 0))
    .ignoresSafeArea(.all)
}

#Preview("Track user location with Course") {
    MapView(
        styleURL: demoTilesURL,
        camera: .constant(.trackUserLocationWithCourse(zoom: 4, pitch: .fixed(45))),
        locationManager: locationManager
    )
    .mapViewContentInset(.init(top: 450, left: 0, bottom: 0, right: 0))
    .hideCompassView()
    .ignoresSafeArea(.all)
}
