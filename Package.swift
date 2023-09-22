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
        .library(
            name: "MapLibreSwiftDSL",
            targets: ["MapLibreSwiftDSL"]),
    ],
    dependencies: [
//        .package(url: "https://github.com/maplibre/maplibre-gl-native-distribution", .upToNextMajor(from: "5.13.0")),
    ],
    targets: [
        .binaryTarget(name: "MapLibre",
                      url: "https://github.com/maplibre/maplibre-native/releases/download/ios-v6.0.0-predd74d1e84a781a41691cfd0de592d153c8795b65/MapLibre.dynamic.xcframework.zip",
                      checksum: "0a9c5a898f699e4acaa1650761f8908213fb5d638c389ed714a2f784349dd3b8"),
        .target(
            name: "MapLibreSwiftUI",
            dependencies: [
                .target(name: "InternalUtils"),
                .target(name: "MapLibreSwiftDSL"),
                .target(name: "MapLibre"),
            ]),
        .target(
            name: "MapLibreSwiftDSL",
            dependencies: [
                .target(name: "InternalUtils"),
                .target(name: "MapLibre"),
            ]),
        .target(name: "InternalUtils"),
        .testTarget(
            name: "MapLibreSwiftDSLTests",
            dependencies: ["MapLibreSwiftDSL"]),
    ]
)
