import CoreLocation
import MapLibre
import MapLibreSwiftDSL
import SwiftUI

#Preview("Unsafe MapView Modifier") {
    MapView<MapViewController>(styleURL: demoTilesURL) {
        // A collection of points with various
        // attributes
        let pointSource = ShapeSource(identifier: "points") {
            // Uses the DSL to quickly construct point features inline
            MLNPointFeature(coordinate: CLLocationCoordinate2D(latitude: 51.47778, longitude: -0.00139))

            MLNPointFeature(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)) { feature in
                feature.attributes["icon"] = "missing"
                feature.attributes["heading"] = 45
            }

            MLNPointFeature(coordinate: CLLocationCoordinate2D(latitude: 39.02001, longitude: 1.482148)) { feature in
                feature.attributes["icon"] = "club"
                feature.attributes["heading"] = 145
            }
        }

        // Demonstrates how to use the unsafeMapModifier to set MLNMapView properties that have not been exposed as
        // modifiers yet.
        SymbolStyleLayer(identifier: "simple-symbols", source: pointSource)
            .iconImage(UIImage(systemName: "mappin")!)
    }
    .unsafeMapViewControllerModifier { viewController in
        // Not all properties have modifiers yet. Until they do, you can use this 'escape hatch' to the underlying
        // MLNMapView. Be careful: if you modify properties that the DSL controls already, they may be overridden. This
        // modifier is a "hack", not a final function.
		viewController.mapView.logoView.isHidden = false
		viewController.mapView.compassViewPosition = .topLeft
    }
}
