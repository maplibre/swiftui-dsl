import InternalUtils
import MapLibre
import MapLibreSwiftDSL
import SwiftUI

struct PolylineMapView: View {
    let styleURL: URL
    let waypoints: [CLLocationCoordinate2D]

    var body: some View {
        MapView(styleURL: styleURL,
                camera: .constant(.center(waypoints.first!, zoom: 14)))
        {
            // Define a data source.
            // It will be automatically if a layer references it.
            let polylineSource = ShapeSource(identifier: "polyline") {
                MLNPolylineFeature(coordinates: waypoints)
            }

            // Add a polyline casing for a stroke effect
            LineStyleLayer(identifier: "polyline-casing", source: polylineSource)
                .lineCap(.round)
                .lineJoin(.round)
                .lineColor(.white)
                .lineWidth(interpolatedBy: .zoomLevel,
                           curveType: .exponential,
                           parameters: NSExpression(forConstantValue: 1.5),
                           stops: NSExpression(forConstantValue: [14: 6, 18: 24]))
                // Not required as this is the default; demonstration to be explicit
                .renderBelowSymbols()

            // Add an inner (blue) polyline
            LineStyleLayer(identifier: "polyline-inner", source: polylineSource)
                .lineCap(.round)
                .lineJoin(.round)
                .lineColor(.systemBlue)
                .lineWidth(interpolatedBy: .zoomLevel,
                           curveType: .exponential,
                           parameters: NSExpression(forConstantValue: 1.5),
                           stops: NSExpression(forConstantValue: [14: 3, 18: 16]))
                // Not required as this is the default; demonstration to be explicit
                .renderBelowSymbols()
        }
    }
}

struct Polyline_Previews: PreviewProvider {
    static var previews: some View {
        PolylineMapView(styleURL: demoTilesURL, waypoints: samplePedestrianWaypoints)
            .ignoresSafeArea(.all)
    }
}
