// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "MapLibreSwiftUI",
    platforms: [
        .iOS(.v15),
        .macOS(.v11),
    ],
    products: [
        .library(
            name: "MapLibreSwiftUI",
            targets: ["MapLibreSwiftUI"]),
        .library(
            name: "MapLibreSwiftDSL",
            targets: ["MapLibreSwiftDSL"]),
        .library(
            name: "MapLibre",
            targets: ["MapLibre"])
    ],
    dependencies: [
//        .package(url: "https://github.com/maplibre/maplibre-gl-native-distribution", .upToNextMajor(from: "5.13.0")),
        .package(url: "https://github.com/stadiamaps/maplibre-swift-macros.git", branch: "main")
    ],
    targets: [
        .binaryTarget(
            name: "MapLibre",
            url: "https://github.com/maplibre/maplibre-native/releases/download/ios-v6.0.0-pre9fbcb031f019048f21fdfcb57b80f4451cdecfd9/MapLibre.dynamic.xcframework.zip",
            checksum: "929bbc3f24740df360bf447acf08bd102cf4baf12a6bc099f42e5fb8b5130cf4"
        ),
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
                .product(name: "MapLibreSwiftMacros", package: "maplibre-swift-macros")
            ]
        ),
        .target(
            name: "InternalUtils"
        ),
        
        // MARK: Tests
        
        .testTarget(
            name: "MapLibreSwiftDSLTests",
            dependencies: [
                "MapLibreSwiftDSL"
            ]
        ),
    ]
)
