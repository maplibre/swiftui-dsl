import InternalUtils
import MapLibre
import MapLibreSwiftDSL
import SwiftUI

struct PolylinePreview: View {
    let styleURL: URL

    var body: some View {
        MapView(styleURL: styleURL,
                constantCamera: .center(samplePedestrianWaypoints.first!, zoom: 14))
        {
            // Note: This line does not add the source to the style as if it
            // were a statement in an imperative programming language.
            // The source is added automatically if a layer references it.
            let polylineSource = ShapeSource(identifier: "pedestrian-polyline") {
                MLNPolylineFeature(coordinates: samplePedestrianWaypoints)
            }

            // Add a polyline casing for a stroke effect
            LineStyleLayer(identifier: "route-line-casing", source: polylineSource)
                .lineCap(.round)
                .lineJoin(.round)
                .lineColor(.white)
                .lineWidth(interpolatedBy: .zoomLevel,
                           curveType: .exponential,
                           parameters: NSExpression(forConstantValue: 1.5),
                           stops: NSExpression(forConstantValue: [14: 6, 18: 24]))

            // Add an inner (blue) polyline
            LineStyleLayer(identifier: "route-line-inner", source: polylineSource)
                .lineCap(.round)
                .lineJoin(.round)
                .lineColor(.systemBlue)
                .lineWidth(interpolatedBy: .zoomLevel,
                           curveType: .exponential,
                           parameters: NSExpression(forConstantValue: 1.5),
                           stops: NSExpression(forConstantValue: [14: 3, 18: 16]))
        }
        .previewDisplayName("Polyline")
    }
}

struct Polyline_Previews: PreviewProvider {
    static var previews: some View {
        let demoTilesURL = URL(string: "https://demotiles.maplibre.org/style.json")!

        PolylinePreview(styleURL: demoTilesURL)
            .ignoresSafeArea(.all)
    }
}
