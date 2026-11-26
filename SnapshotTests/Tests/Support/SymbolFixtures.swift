import CoreLocation
import MapLibre
import MapLibreSwiftDSL

@MainActor
func symbolTestSource(around center: CLLocationCoordinate2D) -> ShapeSource {
    ShapeSource(identifier: "points") {
        MLNPointFeature(coordinate: CLLocationCoordinate2D(
            latitude: center.latitude + 0.01,
            longitude: center.longitude - 0.02
        ))

        MLNPointFeature(coordinate: center) { feature in
            feature.attributes["heading"] = 45
        }

        MLNPointFeature(coordinate: CLLocationCoordinate2D(
            latitude: center.latitude - 0.01,
            longitude: center.longitude + 0.02
        )) { feature in
            feature.attributes["heading"] = 145
        }
    }
}
