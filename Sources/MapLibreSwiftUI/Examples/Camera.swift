import CoreLocation
import SwiftUI

struct CameraDirectManipulationPreview: View {
    @State private var camera = MapViewCamera.center(switzerland, zoom: 4)

    let styleURL: URL
    var onStyleLoaded: (() -> Void)?
    var targetCameraAfterDelay: MapViewCamera?

    var body: some View {
        MapView(styleURL: styleURL, camera: $camera)
            .onStyleLoaded { _ in
                onStyleLoaded?()
            }
            .overlay(alignment: .bottom, content: {
                Text("\(String(describing: camera.state))")
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
                if let targetCameraAfterDelay {
                    try? await Task.sleep(nanoseconds: 3 * NSEC_PER_SEC)

                    camera = targetCameraAfterDelay
                }
            }
    }
}

#Preview("Camera Zoom after delay") {
    CameraDirectManipulationPreview(
        styleURL: demoTilesURL,
        targetCameraAfterDelay: .center(switzerland, zoom: 6)
    )
    .ignoresSafeArea(.all)
}
