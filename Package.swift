// swift-tools-version: 5.10
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
        .library(
            name: "MapLibreSwiftMacros",
            targets: ["MapLibreSwiftMacros"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/maplibre/maplibre-gl-native-distribution.git", from: "6.10.0"),
        // Macros
        .package(url: "https://github.com/swiftlang/swift-syntax.git", "509.0.0" ..< "601.0.0"),
        // Testing
        .package(url: "https://github.com/Kolos65/Mockable.git", from: "0.3.1"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.3"),
        // Macro Testing
        .package(url: "https://github.com/pointfreeco/swift-macro-testing", .upToNextMinor(from: "0.6.0")),
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
                "MapLibreSwiftMacros",
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),
        .target(
            name: "InternalUtils",
            dependencies: [
                .product(name: "MapLibre", package: "maplibre-gl-native-distribution"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),

        // MARK: Macro

        .macro(
            name: "MapLibreSwiftMacrosImpl",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(name: "MapLibreSwiftMacros", dependencies: ["MapLibreSwiftMacrosImpl"]),

        // MARK: Tests

        .testTarget(
            name: "MapLibreSwiftUITests",
            dependencies: [
                "MapLibreSwiftUI",
                .product(name: "Mockable", package: "Mockable"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
        .testTarget(
            name: "MapLibreSwiftDSLTests",
            dependencies: [
                "MapLibreSwiftDSL",
            ]
        ),

        // MARK: Macro Tests

        .testTarget(
            name: "MapLibreSwiftMacrosTests",
            dependencies: [
                "MapLibreSwiftMacrosImpl",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                .product(name: "MacroTesting", package: "swift-macro-testing"),
            ]
        ),
    ]
)
