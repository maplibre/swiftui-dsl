import CoreLocation
import SwiftUI

private let switzerland = CLLocationCoordinate2D(latitude: 46.801111, longitude: 8.226667)

struct CameraDirectManipulationPreview: View {
    @State private var camera = MapViewCamera.center(switzerland, zoom: 4)

    let styleURL: URL

    var body: some View {
        MapView(styleURL: styleURL, camera: $camera)
            .overlay(alignment: .bottom, content: {
                Text("\(camera.coordinate.latitude), \(camera.coordinate.longitude) z \(camera.zoom ?? 0)")
                    .padding()
                    .background(
                        in: .rect(cornerRadii: .init(
                            topLeading: 8,
                            bottomLeading: 8,
                            bottomTrailing: 8,
                            topTrailing: 8)),
                        fillStyle: .init()
                    )
                    .padding(.bottom, 42)
            })
        .task {
            try! await Task.sleep(for: .seconds(3))

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
