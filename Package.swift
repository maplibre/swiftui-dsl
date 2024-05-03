// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "MapLibreSwiftUI",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "MapLibreSwiftUI",
            targets: ["MapLibreSwiftUI"]
        ),
        .library(
            name: "MapLibreSwiftDSL",
            targets: ["MapLibreSwiftDSL"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/maplibre/maplibre-gl-native-distribution.git", from: "6.4.0"),
        .package(url: "https://github.com/stadiamaps/maplibre-swift-macros.git", from: "0.0.3"),
        // Testing
        .package(url: "https://github.com/Kolos65/Mockable.git", exact: "0.0.3"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.15.3"),
    ],
    targets: [
        .target(
            name: "MapLibreSwiftUI",
            dependencies: [
                .target(name: "InternalUtils"),
                .target(name: "MapLibreSwiftDSL"),
                .product(name: "MapLibre", package: "maplibre-gl-native-distribution"),
                .product(name: "Mockable", package: "Mockable"),
            ],
            swiftSettings: [
                .define("MOCKING", .when(configuration: .debug)),
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),
        .target(
            name: "MapLibreSwiftDSL",
            dependencies: [
                .target(name: "InternalUtils"),
                .product(name: "MapLibre", package: "maplibre-gl-native-distribution"),
                .product(name: "MapLibreSwiftMacros", package: "maplibre-swift-macros"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),
        .target(
            name: "InternalUtils",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),

        // MARK: Tests

        .testTarget(
            name: "MapLibreSwiftUITests",
            dependencies: [
                "MapLibreSwiftUI",
                .product(name: "MockableTest", package: "Mockable"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
        .testTarget(
            name: "MapLibreSwiftDSLTests",
            dependencies: [
                "MapLibreSwiftDSL",
            ]
        ),
    ]
)
