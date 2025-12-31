import CoreLocation
import MapLibre
import MapLibreSwiftDSL
import SwiftUI

#Preview("Unsafe MapView Modifier") {
    MapView(styleURL: demoTilesURL, camera: .constant(.center(CLLocationCoordinate2D(), zoom: 0.0))) {
        // A collection of points with various
        // attributes
        let pointSource = ShapeSource(identifier: "points") {
            // Uses the DSL to quickly construct point features inline
            MLNPointFeature(coordinate: CLLocationCoordinate2D(latitude: 51.47778, longitude: -0.00139))

            MLNPointFeature(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))

            MLNPointFeature(coordinate: CLLocationCoordinate2D(latitude: 39.02001, longitude: 1.482148))
        }

        // Demonstrates how to use the unsafeMapModifier to set MLNMapView properties that have not been exposed as
        // modifiers yet.
        SymbolStyleLayer(identifier: "simple-symbols", source: pointSource)
            .iconImage(UIImage(systemName: "mappin")!)
    }
    .unsafeMapViewControllerModifier { viewController in
        // Not all properties have modifiers yet. Until they do, you can use this 'escape hatch' to the underlying
        // MLNMapView.
        // Be careful: if you modify properties that the DSL controls already, they may be overridden!
        // This modifier is a temporary solution; let us know your use case(s)
        // so we can build safe support into the DSL.
        viewController.mapView.logoView.isHidden = false
        viewController.mapView.compassViewPosition = .topLeft
    }
}
