// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "MapLibreSwiftUI",
    platforms: [
        .iOS(.v16),
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "MapLibreSwiftUI",
            targets: ["MapLibreSwiftUI"]),
        .library(
            name: "MapLibreSwiftDSL",
            targets: ["MapLibreSwiftDSL"]),
        .library(name: "MapLibre", targets: ["MapLibre"])
    ],
    dependencies: [
//        .package(url: "https://github.com/maplibre/maplibre-gl-native-distribution", .upToNextMajor(from: "5.13.0")),
        .package(url: "https://github.com/apple/swift-syntax.git", .upToNextMajor(from: "509.0.0")),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing", .upToNextMinor(from: "0.1.0")),

    ],
    targets: [
        .macro(
            name: "MapLibreSwiftMacrosImpl",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(
            name: "MapLibreSwiftMacros",
            dependencies: [.target(name: "MapLibreSwiftMacrosImpl")]
        ),
        .binaryTarget(name: "MapLibre",
                      url: "https://github.com/maplibre/maplibre-native/releases/download/ios-v6.0.0-pre9fbcb031f019048f21fdfcb57b80f4451cdecfd9/MapLibre.dynamic.xcframework.zip",
                      checksum: "929bbc3f24740df360bf447acf08bd102cf4baf12a6bc099f42e5fb8b5130cf4"),
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
                .target(name: "MapLibreSwiftMacros"),
            ]),
        .target(name: "InternalUtils"),
        .testTarget(
            name: "MapLibreSwiftDSLTests",
            dependencies: [
                "MapLibreSwiftDSL",
                "MapLibreSwiftMacrosImpl",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                .product(name: "MacroTesting", package: "swift-macro-testing"),
            ]),
    ]
)
