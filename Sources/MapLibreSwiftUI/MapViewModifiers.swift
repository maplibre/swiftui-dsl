import Foundation
import MapLibre
import MapLibreSwiftDSL
import SwiftUI

public extension MapView {
    // MARK: Default Gestures

    /// Add an tap gesture handler to the MapView
    ///
    /// - Parameters:
    ///   - count: The number of taps required to run the gesture.
    ///   - onTapChanged: Emits the context whenever the gesture changes (e.g. began, ended, etc), that also contains
    /// information like the latitude and longitude of the tap.
    /// - Returns: The modified map view.
    func onTapMapGesture(count: Int = 1,
                         onTapChanged: @escaping (MapGestureContext) -> Void) -> MapView
    {
        var newMapView = self

        // Build the gesture and link it to the map view.
        let gesture = MapGesture(method: .tap(numberOfTaps: count),
                                 onChange: .context(onTapChanged))
        newMapView.gestures.append(gesture)

        return newMapView
    }

    /// Add an tap gesture handler to the MapView that returns any visible map features that were tapped.
    ///
    /// - Parameters:
    ///   - count: The number of taps required to run the gesture.
    ///   - on layers: The set of layer ids that you would like to check for visible features that were tapped. If no
    /// set is provided, all map layers are checked.
    ///   - onTapChanged: Emits the context whenever the gesture changes (e.g. began, ended, etc), that also contains
    /// information like the latitude and longitude of the tap. Also emits an array of map features that were tapped.
    /// Returns an empty array when nothing was tapped on the "on" layer ids that were provided.
    /// - Returns: The modified map view.
    func onTapMapGesture(count: Int = 1, on layers: Set<String>?,
                         onTapChanged: @escaping (MapGestureContext, [any MLNFeature]) -> Void) -> MapView
    {
        var newMapView = self

        // Build the gesture and link it to the map view.
        let gesture = MapGesture(method: .tap(numberOfTaps: count),
                                 onChange: .feature(onTapChanged, layers: layers))
        newMapView.gestures.append(gesture)

        return newMapView
    }

    /// Add a long press gesture handler to the MapView
    ///
    /// - Parameters:
    ///   - minimumDuration: The minimum duration in seconds the user must press the screen to run the gesture.
    ///   - onPressChanged: Emits the context whenever the gesture changes (e.g. began, ended, etc).
    /// - Returns: The modified map view.
    func onLongPressMapGesture(minimumDuration: Double = 0.5,
                               onPressChanged: @escaping (MapGestureContext) -> Void) -> MapView
    {
        var newMapView = self

        // Build the gesture and link it to the map view.
        let gesture = MapGesture(method: .longPress(minimumDuration: minimumDuration),
                                 onChange: .context(onPressChanged))
        newMapView.gestures.append(gesture)

        return newMapView
    }
}
