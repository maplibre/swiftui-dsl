import CoreLocation
import MapLibre
import MapLibreSwiftDSL
import SwiftUI

private let cookStrait = CLLocationCoordinate2D(latitude: -41.3, longitude: 174.4)

struct StyleLayerUpdatesPreview: View {
    
    /// The number of updates for one turn of the ring.
    var stepsPerTurn = 10
    
    /// The time between two updates, in seconds.
    ///
    /// SwiftUI draws at most one update per frame. If the interval is shorter than a frame, SwiftUI skips updates.
    var interval: TimeInterval = 0.5
    
    /// The number of points in the source.
    var pointCount = 24

    @State private var iteration = 0
    @State private var updatesPerSecond: Double = 0
    @State private var camera = MapViewCamera.center(cookStrait, zoom: 7)

    private static let colors: [UIColor] = [.systemRed, .systemOrange, .systemGreen, .systemBlue, .systemPurple]

    var body: some View {
        MapView(styleURL: demoTilesURL, camera: $camera) {
            let angle = Double(iteration) / Double(max(stepsPerTurn, 1)) * 2 * .pi
            
            let source = ShapeSource(identifier: "ring") {
                ringFeatures(around: figureEightPoint(at: angle / 4), rotatedBy: angle)
            }

            CircleStyleLayer(identifier: "ring-halo", source: source)
                .radius(14)
                .color(.white)

            CircleStyleLayer(identifier: "ring-points", source: source)
                .radius(8)
                .color(Self.colors[iteration % Self.colors.count])
        
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

    /// Returns a point on a figure eight around `cookStrait`. An `angle` of 2π is one loop.
    private func figureEightPoint(at angle: Double) -> CLLocationCoordinate2D {
        offset(cookStrait, north: 0.35 * sin(2 * angle), east: 0.7 * sin(angle))
    }

    private func ringFeatures(around center: CLLocationCoordinate2D, rotatedBy angle: Double) -> [MLNPointFeature] {
        (0 ..< pointCount).map { index in
            let pointAngle = angle + Double(index) / Double(pointCount) * 2 * .pi
            return MLNPointFeature(coordinate: offset(
                center,
                north: 0.3 * sin(pointAngle),
                east: 0.3 * cos(pointAngle)
            ))
        }
    }

    /// Returns `coordinate` moved by `north` and `east`, both in degrees of latitude, so that rings stay round.
    private func offset(_ coordinate: CLLocationCoordinate2D, north: Double, east: Double) -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: coordinate.latitude + north,
            longitude: coordinate.longitude + east / cos(coordinate.latitude * .pi / 180)
        )
    }
}

#Preview("Style Layer Updates") {
    StyleLayerUpdatesPreview()
        .ignoresSafeArea(.all)
}

#Preview("Style Layer Updates (Stress)") {
    StyleLayerUpdatesPreview(stepsPerTurn: 240, interval: 1.0 / 60, pointCount: 2000)
        .ignoresSafeArea(.all)
}
