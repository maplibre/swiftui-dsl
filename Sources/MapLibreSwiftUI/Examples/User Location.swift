import CoreLocation
import MapLibre
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
    MapView(
        styleURL: demoTilesURL,
        camera: .constant(.trackUserLocation(zoom: 4, pitch: 45)),
        locationManager: locationManager
    )
    .mapViewContentInset(.init(top: 450, left: 0, bottom: 0, right: 0))
    .ignoresSafeArea(.all)
}

#Preview("Track user location with Course") {
    MapView(
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

#Preview("Track user location with custom annotation") {
    MapView(
        styleURL: demoTilesURL,
        camera: .constant(.trackUserLocation(zoom: 4, pitch: 45)),
        locationManager: locationManager
    )
    .mapViewContentInset(.init(top: 450, left: 0, bottom: 0, right: 0))
    .mapControls {
        LogoView()
    }
    .mapAnnotationStyle(
        MapUserAnnotationStyle(
            approximateHaloBorderColor: .orange,
            approximateHaloBorderWidth: 50,
            approximateHaloFillColor: .orange,
            approximateHaloOpacity: 0.5,
            haloFillColor: .orange,
            puckArrowFillColor: .orange,
            puckFillColor: .orange,
            puckShadowColor: .white,
            puckShadowOpacity: 0.5
        )
    )
    .ignoresSafeArea(.all)
}


#Preview("Track user location with course with custom annotation") {
    MapView(
        styleURL: demoTilesURL,
        camera: .constant(.trackUserLocationWithCourse(zoom: 4, pitch: 45)),
        locationManager: locationManager
    )
    .mapViewContentInset(.init(top: 450, left: 0, bottom: 0, right: 0))
    .mapControls {
        LogoView()
    }
    .mapAnnotationStyle(
        MapUserAnnotationStyle(
            approximateHaloBorderColor: .orange,
            approximateHaloBorderWidth: 50,
            approximateHaloFillColor: .orange,
            approximateHaloOpacity: 0.5,
            haloFillColor: .orange,
            puckArrowFillColor: .orange,
            puckFillColor: .orange,
            puckShadowColor: .white,
            puckShadowOpacity: 0.5
        )
    )
    .ignoresSafeArea(.all)
}

