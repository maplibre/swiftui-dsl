import CoreLocation
import MapLibreSwiftDSL
import SwiftUI

@MainActor
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
    MapView<MapViewController>(
        styleURL: demoTilesURL,
        camera: .constant(.trackUserLocation(zoom: 4, pitch: 45)),
        locationManager: locationManager
    )
    .mapViewContentInset(.init(top: 450, left: 0, bottom: 0, right: 0))
    .ignoresSafeArea(.all)
}

#Preview("Track user location with Course") {
    MapView<MapViewController>(
        styleURL: demoTilesURL,
        camera: .constant(.trackUserLocationWithCourse(zoom: 4, pitch: 45)),
        locationManager: locationManager
    )
    .mapViewContentInset(.init(top: 450, left: 0, bottom: 0, right: 0))
    .mapControls {
        LogoView()
    }
    .ignoresSafeArea(.all)
}
