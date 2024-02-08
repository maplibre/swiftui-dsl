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
    ],
    dependencies: [
//        .package(url: "https://github.com/maplibre/maplibre-gl-native-distribution", .upToNextMajor(from: "5.13.0")),
        .package(url: "https://github.com/maplibre/maplibre-gl-native-distribution.git", from: "6.0.0-preab83392d13e3b4259e8faa9db56ab17671aa112e"),
        .package(url: "https://github.com/stadiamaps/maplibre-swift-macros.git", branch: "main"),
        // Testing
        .package(url: "https://github.com/Kolos65/Mockable.git", from: "0.0.2"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.15.3"),
    ],
    targets: [
        .target(
            name: "MapLibreSwiftUI",
            dependencies: [
                .target(name: "InternalUtils"),
                .target(name: "MapLibreSwiftDSL"),
                .product(name: "MapLibre", package: "maplibre-gl-native-distribution"),
                .product(name: "Mockable", package: "Mockable")
            ],
            swiftSettings: [
                .define("MOCKING", .when(configuration: .debug))
            ]),
        .target(
            name: "MapLibreSwiftDSL",
            dependencies: [
                .target(name: "InternalUtils"),
                .product(name: "MapLibre", package: "maplibre-gl-native-distribution"),
                .product(name: "MapLibreSwiftMacros", package: "maplibre-swift-macros")
            ]
        ),
        .target(
            name: "InternalUtils"
        ),
        
        // MARK: Tests
        
        .testTarget(
            name: "MapLibreSwiftUITests",
            dependencies: [
                "MapLibreSwiftUI",
                .product(name: "MockableTest", package: "Mockable"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ]
        ),
        .testTarget(
            name: "MapLibreSwiftDSLTests",
            dependencies: [
                "MapLibreSwiftDSL"
            ]
        ),
    ]
)
