import CoreLocation
import SwiftUI

private let switzerland = CLLocationCoordinate2D(latitude: 46.801111, longitude: 8.226667)

struct CameraDirectManipulationPreview: View {
    @State private var camera = MapView.Camera.centerAndZoom(switzerland, 4)

    let styleURL: URL

    var body: some View {
        MapView(styleURL: styleURL, camera: $camera)
            .overlay(alignment: .bottom, content: {
                switch camera {
                case .centerAndZoom(let coord, let zoom):
                    Text("\(coord.latitude), \(coord.longitude) z \(zoom ?? 0)")
                        .padding()
                        .background(in: RoundedRectangle(cornerRadius: 8), 
                                    fillStyle: .init())
                        .padding(.bottom, 42)
                }
            })
        .task {
            try! await Task.sleep(nanoseconds: 3_000_000_000)

            camera = MapView.Camera.centerAndZoom(switzerland, 6)
        }
    }
}

struct Camera_Previews: PreviewProvider {
    static var previews: some View {
        let demoTilesURL = URL(string: "https://demotiles.maplibre.org/style.json")!

        CameraDirectManipulationPreview(styleURL: demoTilesURL)
            .ignoresSafeArea(.all)
            .previewDisplayName("Camera Binding")
    }
}
