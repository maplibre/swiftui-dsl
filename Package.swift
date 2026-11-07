// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let enableDeveloperTools = false
let defaultTraits: Set<String> = if enableDeveloperTools {
    ["MapLibreDeveloper"]
} else {
    []
}

let swift6Settings: [SwiftSetting] = [
    .defaultIsolation(nil),
    .enableUpcomingFeature("InferIsolatedConformances"),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
]

let package = Package(
    name: "MapLibreSwiftUI",
    platforms: [
        .iOS("15.5"),
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
    traits: [
        .default(enabledTraits: defaultTraits),
        .trait(name: "MapLibreDeveloper"),
    ],
    dependencies: [
        .package(url: "https://github.com/maplibre/maplibre-gl-native-distribution.git", from: "7.0.0"),
        // Macros
        .package(url: "https://github.com/swiftlang/swift-syntax.git", "509.0.0" ..< "603.0.0"),
        // Testing
        .package(url: "https://github.com/apple/swift-numerics.git", from: "1.1.1"),
        .package(url: "https://github.com/Kolos65/Mockable.git", from: "0.5.1"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.7"),
        // Macro Testing
        .package(url: "https://github.com/pointfreeco/swift-macro-testing", .upToNextMinor(from: "0.6.4")),
    ],
    targets: [
        .target(
            name: "MapLibreSwiftUI",
            dependencies: [
                .target(name: "InternalUtils"),
                .target(name: "MapLibreSwiftDSL"),
                .product(name: "MapLibre", package: "maplibre-gl-native-distribution"),
                .product(name: "Mockable", package: "Mockable", condition: .when(traits: ["MapLibreDeveloper"])),
            ],
            swiftSettings: swift6Settings + [
                .define("MOCKING", .when(configuration: .debug)),
            ]
        ),
        .target(
            name: "MapLibreSwiftDSL",
            dependencies: [
                .target(name: "InternalUtils"),
                .product(name: "MapLibre", package: "maplibre-gl-native-distribution"),
                "MapLibreSwiftMacros",
            ],
            swiftSettings: swift6Settings
        ),
        .target(
            name: "InternalUtils",
            dependencies: [
                .product(name: "MapLibre", package: "maplibre-gl-native-distribution"),
            ],
            swiftSettings: swift6Settings
        ),

        // MARK: Macro

        .macro(
            name: "MapLibreSwiftMacrosImpl",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
            swiftSettings: swift6Settings
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(
            name: "MapLibreSwiftMacros",
            dependencies: ["MapLibreSwiftMacrosImpl"],
            swiftSettings: swift6Settings
        ),

        // MARK: Tests

        .testTarget(
            name: "MapLibreSwiftUITests",
            dependencies: [
                "MapLibreSwiftUI",
                .product(name: "MapLibre", package: "maplibre-gl-native-distribution"),
                .product(name: "Numerics", package: "swift-numerics"),
                .product(name: "Mockable", package: "Mockable"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ],
            swiftSettings: swift6Settings
        ),
        .testTarget(
            name: "MapLibreSwiftDSLTests",
            dependencies: [
                "MapLibreSwiftDSL",
            ],
            swiftSettings: swift6Settings
        ),

        // MARK: Macro Tests

        .testTarget(
            name: "MapLibreSwiftMacrosTests",
            dependencies: [
                "MapLibreSwiftMacrosImpl",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                .product(name: "MacroTesting", package: "swift-macro-testing"),
            ],
            swiftSettings: swift6Settings
        ),
    ],
    swiftLanguageModes: [.v6]
)
