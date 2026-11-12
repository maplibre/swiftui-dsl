import CoreLocation
import MapLibre
import MapLibreSwiftDSL
import SwiftUI

struct CameraDirectManipulationPreview: View {
    @State private var camera = MapViewCamera.center(switzerland, zoom: 4)

    let styleURL: URL
    var onStyleLoaded: (() -> Void)?
    var targetCameraAfterDelay: MapViewCamera?

    var body: some View {
        MapView(styleURL: styleURL, camera: $camera)
            .onMapStyleLoaded { _ in
                print("Style Loaded")
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
                    .padding(.horizontal)
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

struct CameraShowcasePolylinePreview: View {
    let styleURL: URL

    private let waypoints: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 47.3769, longitude: 8.5417), // Zurich
        CLLocationCoordinate2D(latitude: 47.0502, longitude: 8.3093), // Lucerne
        CLLocationCoordinate2D(latitude: 46.9479, longitude: 7.4446), // Bern
    ]

    private var showcaseShapeCollection: MLNShapeCollection {
        MLNShapeCollection(shapes: [MLNPolylineFeature(coordinates: waypoints)])
    }

    private var showcaseCamera: MapViewCamera {
        .showcase(
            shapeCollection: showcaseShapeCollection,
            edgePadding: .init(top: 80, left: 24, bottom: 120, right: 24)
        )
    }

    var body: some View {
        MapView(styleURL: styleURL, camera: .constant(showcaseCamera)) {
            let polylineSource = ShapeSource(identifier: "camera-showcase-polyline") {
                MLNPolylineFeature(coordinates: waypoints)
            }

            LineStyleLayer(identifier: "camera-showcase-polyline-line", source: polylineSource)
                .lineCap(.round)
                .lineJoin(.round)
                .lineColor(.systemBlue)
                .lineWidth(4)
        }
    }
}

#Preview("Camera Showcase Polyline") {
    CameraShowcasePolylinePreview(styleURL: demoTilesURL)
        .ignoresSafeArea(.all)
}
