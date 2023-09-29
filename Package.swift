// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "MapLibreSwiftUI",
    platforms: [
        // DISCUSS: Determine minimum support target; iOS 16 and 17 bring significant improvements to SwiftUI, but it's still TBD what we can get away with supporting.
        .iOS(.v17), .macOS(.v13),
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
