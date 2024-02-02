// This file contains modifiers that are internal and specific to the MapView.
// They are not intended to be exposed directly in the public interface.

import Foundation
import SwiftUI
import MapLibre

extension MapView {
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
    ///     .mapViewModifier { mapView in
    ///         mapView.showUserLocation = true
    ///     }
    /// ```
    ///
    public func unsafeMapViewModifier(_ modifier: @escaping (MLNMapView) -> Void) -> MapView {
        var newMapView = self
        newMapView.unsafeMapViewModifier = modifier
        return newMapView
    }
    
    // MARK: Default Gestures
    
    public func onTapMapGesture(onTapChanged: @escaping (MapGestureContext) -> Void) -> MapView {
        var newMapView = self
        
        // Build the gesture and link it to the map view.
        let gesture = MapGesture(method: .tap, action: onTapChanged)
        newMapView.gestures.append(gesture)
        
        return newMapView
    }
    
    public func onLongPressMapGesture(onPressChanged: @escaping (MapGestureContext) -> Void) -> MapView {
        var newMapView = self
        
        // Build the gesture and link it to the map view.
        let gesture = MapGesture(method: .longPress, action: onPressChanged)
        newMapView.gestures.append(gesture)
        
        return newMapView
    }
}
