import CoreLocation
import MapLibreSwiftUI
import MapLibreSwiftDSL
import SwiftUI

private let switzerland = CLLocationCoordinate2D(latitude: 46.801111, longitude: 8.226667)

struct BackgroundLayerPreview: View {
    @State private var camera = MapView.Camera.centerAndZoom(switzerland, 4)

    let styleURL: URL

    var body: some View {
        MapView(styleURL: styleURL) {
            // Silly example: a background layer on top of everything to create a tint effect
            BackgroundLayer(identifier: "rose-colored-glasses")
                .backgroundColor(.systemPink.withAlphaComponent(0.3))
                .renderAboveOthers()
        }
    }
}

struct Layer_Previews: PreviewProvider {
    static var previews: some View {
        let demoTilesURL = URL(string: "https://demotiles.maplibre.org/style.json")!

        BackgroundLayerPreview(styleURL: demoTilesURL)
            .edgesIgnoringSafeArea(.all)
            .previewDisplayName("Rose Tint")
    }
}
