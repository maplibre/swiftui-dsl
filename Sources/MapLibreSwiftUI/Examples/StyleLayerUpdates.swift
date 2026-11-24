import CoreLocation
import MapLibre
import MapLibreSwiftDSL
import SwiftUI

/// A closed loop of towns around New Zealand. The last coordinate repeats the first.
private let newZealandLoop: [CLLocationCoordinate2D] = [
    CLLocationCoordinate2D(latitude: -34.43, longitude: 172.68), // Cape Reinga
    CLLocationCoordinate2D(latitude: -36.85, longitude: 174.76), // Auckland
    CLLocationCoordinate2D(latitude: -38.66, longitude: 178.02), // Gisborne
    CLLocationCoordinate2D(latitude: -41.29, longitude: 174.78), // Wellington
    CLLocationCoordinate2D(latitude: -43.53, longitude: 172.64), // Christchurch
    CLLocationCoordinate2D(latitude: -45.88, longitude: 170.50), // Dunedin
    CLLocationCoordinate2D(latitude: -46.41, longitude: 168.35), // Invercargill
    CLLocationCoordinate2D(latitude: -44.67, longitude: 167.93), // Milford Sound
    CLLocationCoordinate2D(latitude: -42.72, longitude: 170.97), // Hokitika
    CLLocationCoordinate2D(latitude: -41.27, longitude: 173.28), // Nelson
    CLLocationCoordinate2D(latitude: -39.06, longitude: 174.08), // New Plymouth
    CLLocationCoordinate2D(latitude: -34.43, longitude: 172.68), // Cape Reinga
]

struct StyleLayerUpdatesPreview: View {
    /// The number of updates for one lap of the loop.
    var stepsPerLap = 120

    /// The time between two updates, in seconds.
    ///
    /// SwiftUI draws at most one update per frame. If the interval is shorter than a frame, SwiftUI skips updates.
    var interval: TimeInterval = 1.0 / 30

    /// The number of dots in the star, from the head to the end of the tail.
    var dotCount = 12

    /// The part of the lap that the tail covers, from 0 to 1.
    var tailLength = 0.12

    @State private var iteration = 0
    @State private var updatesPerSecond: Double = 0
    @State private var camera = MapViewCamera.center(
        CLLocationCoordinate2D(latitude: -40.8, longitude: 173.0),
        zoom: 4.3
    )

    var body: some View {
        MapView(styleURL: demoTilesURL, camera: $camera) {
            let route = ShapeSource(identifier: "route") {
                MLNPolylineFeature(coordinates: newZealandLoop)
            }
            let star = ShapeSource(identifier: "star") {
                starFeatures(headAt: Double(iteration) / Double(max(stepsPerLap, 1)))
            }

            LineStyleLayer(identifier: "route", source: route)
                .lineColor(.white)
                .lineOpacity(0.4)
                .lineWidth(1)

            CircleStyleLayer(identifier: "star-glow", source: star)
                .radius(featurePropertyNamed: "glowRadius")
                .color(featurePropertyNamed: "color")
                .circleOpacity(0.25)
                .circleBlur(1)

            CircleStyleLayer(identifier: "star", source: star)
                .radius(featurePropertyNamed: "radius")
                .color(featurePropertyNamed: "color")
                .circleOpacity(featurePropertyNamed: "opacity")
        }
        .overlay(alignment: .bottom) {
            Text("Update \(iteration) · \(updatesPerSecond, specifier: "%.1f") per second")
                .monospacedDigit()
                .padding()
                .foregroundColor(.white)
                .background(.black, in: RoundedRectangle(cornerRadius: 8))
                .padding(.bottom, 64)
        }
        .task {
            let start = Date()
            while true {
                do {
                    try await Task.sleep(nanoseconds: UInt64(interval * Double(NSEC_PER_SEC)))
                } catch {
                    return
                }
                iteration += 1
                updatesPerSecond = Double(iteration) / Date().timeIntervalSince(start)
            }
        }
    }

    /// Returns the dots of the star, from the head to the end of the tail.
    ///
    /// - Parameter head: The position of the head, as a part of the lap. Values above 1 start a new lap.
    private func starFeatures(headAt head: Double) -> [MLNPointFeature] {
        (0 ..< dotCount).map { index in
            // 0 at the head, 1 at the end of the tail.
            let fraction = dotCount > 1 ? Double(index) / Double(dotCount - 1) : 0
            let feature = MLNPointFeature(coordinate: coordinate(at: head - fraction * tailLength))
            feature.attributes = [
                "color": UIColor(hue: fraction * 0.85, saturation: 1, brightness: 1, alpha: 1).hexString,
                "radius": 10 - 7 * fraction,
                "glowRadius": 2 * (10 - 7 * fraction),
                "opacity": 1 - 0.8 * fraction,
            ]
            return feature
        }
    }

    private func coordinate(at progress: Double) -> CLLocationCoordinate2D {
        let position = (progress - progress.rounded(.down)) * Double(newZealandLoop.count - 1)
        let index = Int(position) % (newZealandLoop.count - 1)
        let fraction = position - position.rounded(.down)
        let start = newZealandLoop[index]
        let end = newZealandLoop[index + 1]
        return CLLocationCoordinate2D(
            latitude: start.latitude + fraction * (end.latitude - start.latitude),
            longitude: start.longitude + fraction * (end.longitude - start.longitude)
        )
    }
}

private extension UIColor {
    /// The color as `#RRGGBB`, which a style expression can read from a feature attribute.
    var hexString: String {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: nil)
        return String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
    }
}

#Preview("Style Layer Updates") {
    StyleLayerUpdatesPreview()
        .ignoresSafeArea(.all)
}

#Preview("Style Layer Updates (Stress)") {
    StyleLayerUpdatesPreview(stepsPerLap: 600, interval: 1.0 / 60, dotCount: 2000, tailLength: 0.3)
        .ignoresSafeArea(.all)
}
