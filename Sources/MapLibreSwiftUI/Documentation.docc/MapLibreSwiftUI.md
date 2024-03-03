# ``MapLibreSwiftUI``

A SwiftUI framework for Maplibre Native iOS. Provides declarative methods for MapLibre inspired by default SwiftUI functionality.

## Overview

```swift
struct MyView: View {
    
    @State var camera: MapViewCamera = .default()

    var body: some View {
        MapView(
            styleURL: URL(string: "https://demotiles.maplibre.org/style.json")!,
            camera: $camera
        ) {
            // Declarative overlay features.
        }
        .onTapMapGesture { context in 
            // Handle tap gesture context
        }
    }
}
```

## Topics

### MapView

- ``MapView``

### MapViewCamera

- ``MapViewCamera``
- ``CameraState``
- ``CameraPitch``
- ``CameraChangeReason``

