# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Version 0.2.0 - 2024-10-07

### Added

- `MLNMapViewCameraUpdating.setUserTrackingMode(_ mode: MLNUserTrackingMode, animated: Bool, completionHandler: (() -> Void)?)`
  in [#53](https://github.com/maplibre/swiftui-dsl/pull/53).
  Previously, you could only call `mapViewCameraUpdating.userTrackingMode = newMode`
  without specifying `animated` or `completionHandler`.

### Fixed

- Fix broken animation when setting user tracking mode in [#53](https://github.com/maplibre/swiftui-dsl/pull/53).
  For example, when tapping the "recenter" button in Ferrostar (which uses this
  package), the map now immediately re-centers on the users current location,
  whereas before you'd have to tap it twice. Note: the bug wasn't noticeable
  when using the Ferrostar's SimulatedLocationProvider.
- Pitch range `.free` was being reset to `.freeWithinRange(0, 59.9999999)`
  Fixed in in [#54](https://github.com/maplibre/swiftui-dsl/pull/54).

## Version 0.1.0 - 2024-09-21

This project has migrated from Stadia Maps to the MapLibre organization!
To celebrate, we're bumping the version and adding a CHANGELOG.

Xcode and GitHub normally handle these sorts of changes well,
but sometimes they don't.
So, you'll probably want to be proactive and change your URLs from
`https://github.com/stadiamaps/maplibre-swiftui-dsl-playground`
to `https://github.com/maplibre/swiftui-dsl`.

If you're building a plain Xcode project, it might actually be easier to remove the Swift Package
and all of its targets and then re-add with the URL.

Swift Package authors can simply update the URLs.
Note that the package name also changes with the repo name.

```swift
    .product(name: "MapLibreSwiftDSL", package: "swiftui-dsl"),
    .product(name: "MapLibreSwiftUI", package: "swiftui-dsl"),
```
