import CoreLocation
import SwiftUI

private let switzerland = CLLocationCoordinate2D(latitude: 46.801111, longitude: 8.226667)

struct CameraDirectManipulationPreview: View {
    @State private var camera = MapViewCamera.center(switzerland, zoom: 4)

    let styleURL: URL

    var body: some View {
        MapView(styleURL: styleURL, camera: $camera)
            .overlay(alignment: .bottom, content: {
                Text("\(camera.coordinate.latitude), \(camera.coordinate.longitude) z \(camera.zoom)")
                    .padding()
                    .foregroundColor(.white)
                    .background(
                        Rectangle()
                            .foregroundColor(.black)
                            .cornerRadius(8)
                    )
                    .padding(.bottom, 42)
            })
        .task {
            try! await Task.sleep(nanoseconds: 3 * NSEC_PER_SEC)

            camera = MapViewCamera.center(switzerland, zoom: 6)
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
