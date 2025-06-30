<p align="center">
  <img src="https://github.com/user-attachments/assets/7ff2cda8-f564-4e70-a971-d34152f969f0#gh-light-mode-only" alt="MapLibre Logo" width="200">
  <img src="https://github.com/user-attachments/assets/cee8376b-9812-40ff-91c6-2d53f9581b83#gh-dark-mode-only" alt="MapLibre Logo" width="200">
</p>

# MapLibreSwiftUI

Swift DSLs for [MapLibre Native](https://github.com/maplibre/maplibre-native), a free open-source renderer
for interactive vector maps, to enable better integration with SwiftUI and generally enable easier use of MapLibre.

**NOTE: This package has migrated from Stadia Maps to the MapLibre organization 🎉**
If you previously installed this package, refer to [MIGRATING.md](MIGRATING.md).

![A screen recording demonstrating the declarative SwiftUI DSL reacting to changes live](demo.gif)

This package is a reimagining of the MapLibre API with a modern DSLs for SwiftUI.
The pre-1.0 status means only that we are not yet committed to API stability yet,
since we care deeply about finding the best way to express things for SwfitUI users.
The package is robust for the subset of the MapLibre iOS API that it supports.
Any breaking API changes will be reflected in release notes.

## Goals

1. Primary: Make common use cases easy and [make complicated ones possible](Sources/MapLibreSwiftUI/Examples/Other.swift)
    * Easy integration of MapLibre into a modern SwiftUI app
    * Add [markers](Sources/MapLibreSwiftUI/Examples/Gestures.swift), [polylines](Sources/MapLibreSwiftUI/Examples/Polyline.swift) and similar annotations
    * Interaction with features through [gestures](Sources/MapLibreSwiftUI/Examples/Gestures.swift)
    * Clustering (common use case that's rather difficult for first timers)
    * [Overlays](Sources/MapLibreSwiftUI/Examples/)
    * Dynamic styling
    * [Camera control](Sources/MapLibreSwiftUI/Examples/Camera.swift)
    * Turn-by-turn Navigation (see the showcase integrations below)
    * Animation
2. Prevent most common classes of mistakes that users make with the lower level APIs (ex: adding the same source twice)
3. Deeper SwiftUI integration (ex: SwiftUI callout views)

## Quick start

### In a normal Xcode project

If you're building an app using an Xcode project,
the easiest way to add package dependencies is in the File menu.
Search for the package using the repository URL: `https://github.com/maplibre/swiftui-dsl`.

### In a Swift package 

Add the following to the main dependencies section of your `Package.swift`.

```swift
    .package(url: "https://github.com/maplibre/swiftui-dsl", branch: "main"),
```

Then, for each target add either the DSL (for just the DSL) or both (for the SwiftUI view):

```swift
    .product(name: "MapLibreSwiftDSL", package: "swiftui-dsl"),
    .product(name: "MapLibreSwiftUI", package: "swiftui-dsl"),
```

### Simple example: polyline rendering

Then, you can use it in a SwiftUI view body like this:

```swift
import MapLibre
import MapLibreSwiftDSL
import SwiftUI
import CoreLocation

struct PolylineMapView: View {
    // You'll need a MapLibre Style for this to work.
    // You can use https://demotiles.maplibre.org/style.json for basic testing.
    // For a list of commercially supported tile providers, check out https://wiki.openstreetmap.org/wiki/Vector_tiles#Providers.
    // These providers all have their own "house styles" as well as custom styling.
    // You can create your own style or modify others (subject to license restrictions) using https://maplibre.org/maputnik/. 
    let styleURL: URL
    
    // Just a list of waypoints (ex: a route to follow)
    let waypoints: [CLLocationCoordinate2D]

    var body: some View {
        MapView(styleURL: styleURL,
                camera: .constant(.center(waypoints.first!, zoom: 14)))
        {
            // Define a data source.
            // It will be automatically if a layer references it.
            let polylineSource = ShapeSource(identifier: "polyline") {
                MLNPolylineFeature(coordinates: waypoints)
            }

            // Add a polyline casing for a stroke effect
            LineStyleLayer(identifier: "polyline-casing", source: polylineSource)
                .lineCap(.round)
                .lineJoin(.round)
                .lineColor(.white)
                .lineWidth(interpolatedBy: .zoomLevel,
                           curveType: .exponential,
                           parameters: NSExpression(forConstantValue: 1.5),
                           stops: NSExpression(forConstantValue: [14: 6, 18: 24]))

            // Add an inner (blue) polyline
            LineStyleLayer(identifier: "polyline-inner", source: polylineSource)
                .lineCap(.round)
                .lineJoin(.round)
                .lineColor(.systemBlue)
                .lineWidth(interpolatedBy: .zoomLevel,
                           curveType: .exponential,
                           parameters: NSExpression(forConstantValue: 1.5),
                           stops: NSExpression(forConstantValue: [14: 3, 18: 16]))
        }
    }
}
```

Check out more [Examples](Sources/MapLibreSwiftUI/Examples) to go deeper.

**NOTE: This currently only works on iOS, as the dynamic framework doesn't yet include macOS.**

## How can you help?

The first thing you can do is try it out!
Check out the [Examples](Sources/MapLibreSwiftUI/Examples) for inspiration,
swap it into your own SwiftUI app, or check out some showcase integrations for inspiration.
Putting it "through the paces" is the best way for us to converge on the "right" APIs as a community.
Your use case probably isn't supported today, in which case you can either open an issue or contribute a PR.

The code has a number of TODOs, most of which can be tackled by any intermediate Swift programmer.
The important issues should all be tracked in GitHub.
We also have a `#maplibre-swiftui` channel in the
[OpenStreetMap US Slack](https://slack.openstreetmap.us/).
(For nonspecific questions about MapLibre on iOS, there's also a `#maplibre-ios` channel).

The skeleton is already in place for several of the core concepts, including style layers and sources, but
these are incomplete. You can help by opening a PR that fills these in.
For example, if you wanted to fill out the API for the line style layer,
head over to [the docs](https://maplibre.org/maplibre-native/ios/api/Classes/MGLLineStyleLayer.html)
and just start filling out the remaining properties and modifiers.

## Showcase integrations

### Ferrostar

[Ferrostar](https://github.com/stadiamaps/ferrostar) has a MapLibre UI module as part of its Swift Package.
That was actually the impetus for building this package,
and the core devs are eating their own dogfood.
See the [SwiftUI customization](https://stadiamaps.github.io/ferrostar/swiftui-customization.html)
part of the Ferrostar user guide for details on how to customize the map.

### MapLibre Navigation iOS

This package also helps to bridge the gap between MapLibre Navigation iOS and SwiftUI!
Thanks to developers from [HudHud](https://hudhud.sa/en) for their contributions which made this possible!

Add the [Swift Package](https://github.com/maplibre/maplibre-navigation-ios) to your project.
Then add some code like this:

```swift
import MapboxCoreNavigation
import MapboxNavigation
import MapLibreSwiftUI

extension NavigationViewController: MapViewHostViewController {
    public typealias MapType = NavigationMapView
}


@State var route: Route?
@State var navigationInProgress: Bool = false

@ViewBuilder
var mapView: some View {
    MapView<NavigationViewController>(makeViewController: NavigationViewController(dayStyleURL: self.styleURL), styleURL: self.styleURL, camera: self.$mapStore.camera) {
        // TODO: Your customizations here; add more layers or whatever you like!
    }
    .unsafeMapViewControllerModifier { navigationViewController in
        navigationViewController.delegate = self.mapStore
        if let route = self.route, self.navigationInProgress == false {
            let locationManager = SimulatedLocationManager(route: route)
            navigationViewController.startNavigation(with: route, locationManager: locationManager)
            self.navigationInProgress = true
        } else if self.route == nil, self.navigationInProgress == true {
            navigationViewController.endNavigation()
            self.navigationInProgress = false
        }

        navigationViewController.mapView.showsUserLocation = self.showUserLocation && self.mapStore.streetView == .disabled
    }
    .cameraModifierDisabled(self.route != nil)
}
```
