import Foundation
import MapLibre
import MapLibreSwiftDSL
import SwiftUI

public extension MapView {
    /// Perform an action when the map view's user tracking mode has changed
    ///
    /// - Parameter perform: The action to perform on tracking mode change. Inputs are the new user tracking mode and
    /// whether the change was animated.
    /// - Returns: The modified map view.
    func onUserTrackingModeChanged(_ perform: @escaping (MLNUserTrackingMode, Bool) -> Void) -> MapView {
        var newMapView = self
        newMapView.onUserTrackingModeChanged = perform
        return newMapView
    }

    /// Allows you to set properties of the underlying MLNMapView directly
    /// in cases where these have not been ported to DSL yet.
    /// Use this function to modify various properties of the MLNMapView instance.
    /// For example, you can enable the display of the user's location on the map by setting `showUserLocation` to true.
    ///
    /// This is an 'escape hatch' back to the non-DSL world
    /// of MapLibre for features that have not been ported to DSL yet.
    /// Be careful not to use this to modify properties that are
    /// already ported to the DSL, like the camera for example, as your
    /// modifications here may break updates that occur with modifiers.
    /// In particular, this modifier is potentially dangerous as it runs on
    /// EVERY call to `updateUIView`.
    ///
    /// - Parameter modifier: A closure that provides you with an MLNMapView so you can set properties.
    /// - Returns: A MapView with the modifications applied.
    ///
    /// Example:
    /// ```swift
    ///  MapView()
    ///     .unsafeMapViewControllerModifier { controller in
    ///         controller.mapView.showUserLocation = true
    ///     }
    /// ```
    ///
    func unsafeMapViewControllerModifier(_ modifier: @escaping (T) -> Void) -> MapView {
        var newMapView = self
        newMapView.unsafeMapViewControllerModifier = modifier
        return newMapView
    }

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

    /// Add a default implementation for tapping clustered features. When tapped, the map zooms so that the cluster is
    /// expanded.
    /// - Parameter clusteredLayers: An array of layers to monitor that can contain clustered features.
    /// - Returns: The modified MapView
    func expandClustersOnTapping(clusteredLayers: [ClusterLayer]) -> MapView {
        var newMapView = self
        newMapView.clusteredLayers = clusteredLayers
        return newMapView
    }

    func mapViewContentInset(_ inset: UIEdgeInsets) -> Self {
        var result = self
        result.mapViewContentInset = inset
        return result
    }

    func mapControls(@MapControlsBuilder _ buildControls: () -> [MapControl]) -> Self {
        var result = self
        result.controls = buildControls()
        return result
    }

    /// The view modifier recieves an instance of `MapViewProxy`, which contains read only information about the current
    /// state of the
    /// `MapView` such as its bounds, center and insets.
    /// - Parameters:
    ///   - updateMode: How frequently the `MapViewProxy` is updated. Per default this is set to `.onFinish`, so updates
    /// are only sent when the map finally completes updating due to animations or scrolling. Can be set to `.realtime`
    /// to recieve updates during the animations and scrolling too.
    ///   - onViewProxyChanged: The closure containing the `MapViewProxy`. Use this to run code based on the current
    /// mapView state.
    ///
    /// Example:
    /// ```swift
    ///          .onMapViewProxyUpdate() { proxy in
    ///            print("The map zoom level is: \(proxy.zoomLevel)")
    ///          }
    /// ```
    ///
    func onMapViewProxyUpdate(
        updateMode: ProxyUpdateMode = .onFinish,
        onViewProxyChanged: @escaping (MapViewProxy) -> Void
    ) -> Self {
        var result = self
        result.onViewProxyChanged = onViewProxyChanged
        result.proxyUpdateMode = updateMode
        return result
    }

    /// Prevent Maplibre-DSL from updating the camera, useful when the underlying ViewController is managing the camera,
    /// for example during navigation when Maplibre-Navigation is used.
    /// - Parameter disabled: if true, prevents Maplibre-DSL from updating the camera
    /// - Returns: The modified MapView
    func cameraModifierDisabled(_ disabled: Bool) -> Self {
        var view = self
        view.cameraDisabled = disabled
        return view
    }
}
