// This file contains helpers that are used in the SwiftUI preview examples
import CoreLocation

let switzerland = CLLocationCoordinate2D(latitude: 47.03041, longitude: 8.29470)
public let demoTilesURL = URL(string: "https://demotiles.maplibre.org/style.json")!

let austriaPolygon: [CLLocationCoordinate2D] = [
    CLLocationCoordinate2D(latitude: 49.0200, longitude: 16.9600),
    CLLocationCoordinate2D(latitude: 48.9000, longitude: 15.0160),
    CLLocationCoordinate2D(latitude: 48.2890, longitude: 13.0310),
    CLLocationCoordinate2D(latitude: 47.5237, longitude: 10.4350),
    CLLocationCoordinate2D(latitude: 46.4000, longitude: 12.1500),
    CLLocationCoordinate2D(latitude: 46.8700, longitude: 16.5900),
    CLLocationCoordinate2D(latitude: 48.1234, longitude: 16.9600), 
    CLLocationCoordinate2D(latitude: 49.0200, longitude: 16.9600)  // Closing point (same as start)
]
