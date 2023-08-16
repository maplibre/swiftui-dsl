// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MapLibreSwiftUI",
    platforms: [
        // DISCUSS: Determine minimum support target; iOS 16 and 17 bring significant improvements to SwiftUI, but it's still TBD what we can get away with supporting.
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "MapLibreSwiftUI",
            targets: ["MapLibreSwiftUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/maplibre/maplibre-gl-native-distribution", .upToNextMajor(from: "5.13.0")),
    ],
    targets: [
        .target(
            name: "MapLibreSwiftUI",
            dependencies: [
                .product(name: "Mapbox", package: "maplibre-gl-native-distribution"),
            ]),
        .testTarget(
            name: "MapLibreSwiftUITests",
            dependencies: ["MapLibreSwiftUI"]),
    ]
)
