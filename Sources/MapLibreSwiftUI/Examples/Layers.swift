import CoreLocation
import MapLibre
import MapLibreSwiftDSL
import SwiftUI

/// A collection of points with various
/// attributes
@MainActor
let pointSource = ShapeSource(identifier: "points") {
    // Uses the DSL to quickly construct point features inline
    MLNPointFeature(coordinate: CLLocationCoordinate2D(latitude: 51.47778, longitude: -0.00139))

    MLNPointFeature(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)) { feature in
        feature.attributes["icon"] = "missing"
        feature.attributes["heading"] = 45
    }

    MLNPointFeature(coordinate: CLLocationCoordinate2D(latitude: 39.02001, longitude: 1.482148)) { feature in
        feature.attributes["icon"] = "club"
        feature.attributes["heading"] = 145
    }
}

@MainActor
let clustered = ShapeSource(identifier: "points", options: [.clustered: true, .clusterRadius: 44]) {
    // Uses the DSL to quickly construct point features inline
    MLNPointFeature(coordinate: CLLocationCoordinate2D(latitude: 48.2082, longitude: 16.3719))

    MLNPointFeature(coordinate: CLLocationCoordinate2D(latitude: 48.3082, longitude: 16.3719))

    MLNPointFeature(coordinate: CLLocationCoordinate2D(latitude: 48.2082, longitude: 16.9719))

    MLNPointFeature(coordinate: CLLocationCoordinate2D(latitude: 48.0082, longitude: 17.9719))
}

#Preview("Rose Tint") {
    MapView(styleURL: demoTilesURL, camera: .constant(.center(CLLocationCoordinate2D(), zoom: 0.0))) {
        // Silly example: a background layer on top of everything to create a tint effect
        BackgroundLayer(identifier: "rose-colored-glasses")
            .backgroundColor(.systemPink.withAlphaComponent(0.3))
            .renderAbove(.all)
    }
    .ignoresSafeArea(.all)
}

#Preview("Simple Symbol") {
    MapView(styleURL: demoTilesURL, camera: .constant(.center(CLLocationCoordinate2D(), zoom: 0.0))) {
        // Simple symbol layer demonstration with an icon
        SymbolStyleLayer(identifier: "simple-symbols", source: pointSource)
            .iconImage(UIImage(systemName: "mappin")!)
    }
    .ignoresSafeArea(.all)
}

#Preview("Rotated Symbols (Const)") {
    MapView(styleURL: demoTilesURL, camera: .constant(.center(CLLocationCoordinate2D(), zoom: 0.0))) {
        // Simple symbol layer demonstration with an icon
        SymbolStyleLayer(identifier: "rotated-symbols", source: pointSource)
            .iconImage(UIImage(systemName: "location.north.circle.fill")!)
            .iconRotation(45)
    }
    .ignoresSafeArea(.all)
}

#Preview("Rotated Symbols (Dynamic)") {
    MapView(styleURL: demoTilesURL, camera: .constant(.center(CLLocationCoordinate2D(), zoom: 0.0))) {
        // Simple symbol layer demonstration with an icon
        SymbolStyleLayer(identifier: "rotated-symbols", source: pointSource)
            .iconImage(UIImage(systemName: "location.north.circle.fill")!)
            .iconRotation(featurePropertyNamed: "heading")
    }
    .ignoresSafeArea(.all)
}

#Preview("Circles with Symbols") {
    MapView(styleURL: demoTilesURL, camera: .constant(.center(CLLocationCoordinate2D(), zoom: 0.0))) {
        // Simple symbol layer demonstration with an icon
        CircleStyleLayer(identifier: "simple-circles", source: pointSource)
            .radius(16)
            .color(.systemRed)
            .strokeWidth(2)
            .strokeColor(.white)

        SymbolStyleLayer(identifier: "simple-symbols", source: pointSource)
            .iconImage(UIImage(systemName: "mappin")!.withRenderingMode(.alwaysTemplate))
            .iconColor(.white)
    }
    .ignoresSafeArea(.all)
}

#Preview("Clustered Circles with Symbols") {
    MapView(styleURL: demoTilesURL, camera: .constant(MapViewCamera.center(
        CLLocationCoordinate2D(latitude: 48.2082, longitude: 16.3719),
        zoom: 5,
        direction: 0
    ))) {
        // Clusters pins when they would touch

        // Cluster == YES shows only those pins that are clustered, using .text
        CircleStyleLayer(identifier: "simple-circles-clusters", source: clustered)
            .radius(16)
            .color(.systemRed)
            .strokeWidth(2)
            .strokeColor(.white)
            .predicate(NSPredicate(format: "cluster == YES"))

        SymbolStyleLayer(identifier: "simple-symbols-clusters", source: clustered)
            .textColor(.white)
            .text(expression: NSExpression(format: "CAST(point_count, 'NSString')"))
            .predicate(NSPredicate(format: "cluster == YES"))

        // Cluster != YES shows only those pins that are not clustered, using an icon
        CircleStyleLayer(identifier: "simple-circles-non-clusters", source: clustered)
            .radius(16)
            .color(.systemRed)
            .strokeWidth(2)
            .strokeColor(.white)
            .predicate(NSPredicate(format: "cluster != YES"))

        SymbolStyleLayer(identifier: "simple-symbols-non-clusters", source: clustered)
            .iconImage(UIImage(systemName: "mappin")!.withRenderingMode(.alwaysTemplate))
            .iconColor(.white)
            .predicate(NSPredicate(format: "cluster != YES"))
    }
    .onTapMapGesture(on: ["simple-circles-non-clusters"], onTapChanged: { _, features in
        print("Tapped on \(features.first?.debugDescription ?? "<nil>")")
    })
    .mapClustersExpandOnTapping(clusteredLayers: [ClusterLayer(
        layerIdentifier: "simple-circles-clusters",
        sourceIdentifier: "points"
    )])
    .ignoresSafeArea(.all)
}

// This example does not work within a package? But it does work when in a real app
// #Preview("Multiple Symbol Icons") {
//    MapView(styleURL: demoTilesURL) {
//        // Simple symbol layer demonstration with an icon
//        SymbolStyleLayer(identifier: "simple-symbols", source: pointSource)
//            .iconImage(featurePropertyNamed: "icon",
//                       mappings: [
//                           "missing": UIImage(systemName: "mappin.slash")!,
//                           "club": UIImage(systemName: "figure.dance")!,
//                       ],
//                       default: UIImage(systemName: "mappin")!)
//            .iconColor(.red)
//    }
//    .ignoresSafeArea(.all)
// }
