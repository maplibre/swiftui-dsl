//
//  NavigationMapView.swift
//
//
//  Created by Patrick Kladek on 23.05.24.
//

import InternalUtils
import MapboxCoreNavigation
import MapboxDirections
import MapboxNavigation
import MapLibre
import MapLibreSwiftDSL
import MapLibreSwiftUI
import SwiftUI

public struct NavigationMapView: UIViewControllerRepresentable {
	public typealias UIViewControllerType = NavigationViewController
	
	@Binding var camera: MapViewCamera

	let styleSource: MapStyleSource
	let userLayers: [StyleLayerDefinition]

	var gestures = [MapGesture]()

	var onStyleLoaded: ((MLNStyle) -> Void)?
	var onViewPortChanged: ((MapViewPort) -> Void)?
	var route: Route?

	public var mapViewContentInset: UIEdgeInsets = .zero

	/// 'Escape hatch' to MLNMapView until we have more modifiers.
	/// See ``unsafeMapViewModifier(_:)``
	var unsafeMapViewModifier: ((MLNMapView) -> Void)?

	var controls: [MapControl] = [
		CompassView(),
		LogoView(),
		AttributionButton(),
	]

	private var locationManager: MLNLocationManager?
	
	var clusteredLayers: [ClusterLayer]?

	public init(
		styleSource: MapStyleSource,
		camera: Binding<MapViewCamera> = .constant(.default()),
		locationManager: MLNLocationManager? = nil,
		@MapViewContentBuilder _ makeMapContent: () -> [StyleLayerDefinition] = { [] }
	) {
		self.styleSource = styleSource
		_camera = camera
		userLayers = makeMapContent()
		self.locationManager = locationManager
	}

	public func makeCoordinator() -> NavigationMapViewCoordinator {
		NavigationMapViewCoordinator(
			parent: self,
			onGesture: { processGesture($0, $1) },
			onViewPortChanged: { onViewPortChanged?($0) }
		)
	}

	public func makeUIViewController(context: Context) -> NavigationViewController {
		let viewController = NavigationViewController(directions: Directions(accessToken: "empty"))
		
		// TODO: its not allowed to change the mapView delegate. find another way to link mapview with coordinator
		// viewController.mapView?.delegate = context.coordinator
		context.coordinator.mapView = viewController.mapView
		
		// Apply modifiers, suppressing camera update propagation (this messes with setting our initial camera as
		// content insets can trigger a change)
		if let mapView = viewController.mapView {
			context.coordinator.updateStyleSource(styleSource, mapView: mapView)

			context.coordinator.suppressCameraUpdatePropagation = true
			applyModifiers(mapView, runUnsafe: false)
			context.coordinator.suppressCameraUpdatePropagation = false
			
			mapView.locationManager = locationManager
			
			context.coordinator.updateCamera(mapView: mapView,
											 camera: $camera.wrappedValue,
											 animated: false)
			mapView.locationManager = mapView.locationManager
			
			// Link the style loaded to the coordinator that emits the delegate event.
			context.coordinator.onStyleLoaded = onStyleLoaded

			// Add all gesture recognizers
			for gesture in gestures {
				self.registerGesture(mapView, context, gesture: gesture)
			}
		}
		
			
		return viewController
	}
	
	public func updateUIViewController(_ uiViewController: NavigationViewController, context: Context) {
		context.coordinator.parent = self
		let mapView = uiViewController.mapView!
		
		applyModifiers(mapView, runUnsafe: true)
		
		// FIXME: This should be a more selective update
		context.coordinator.updateStyleSource(styleSource, mapView: mapView)
		context.coordinator.updateLayers(mapView: mapView)
		
		// FIXME: This isn't exactly telling us if the *map* is loaded, and the docs for setCenter say it needs to be.
		let isStyleLoaded = mapView.style != nil
		context.coordinator.updateCamera(mapView: mapView,
										 camera: $camera.wrappedValue,
										 animated: isStyleLoaded)
		
		if let route {
			let locationManager = SimulatedLocationManager(route: route)
			locationManager.speedMultiplier = 2
			uiViewController.start(with: route, locationManager: locationManager)
		} else {
			uiViewController.endRoute()
		}
	}
	
	public func assign(route: Route?) -> NavigationMapView {
		var newMapView = self
		newMapView.route = route
		return newMapView
	}
}

#Preview {
	MapView(styleURL: demoTilesURL)
		.ignoresSafeArea(.all)
		.previewDisplayName("Vanilla Map")

	// For a larger selection of previews,
	// check out the Examples directory, which
	// has a wide variety of previews,
	// organized into (hopefully) useful groups
}


extension NavigationMapView {
	
	@MainActor func registerGesture(_ mapView: MLNMapView, _ context: Context, gesture: MapGesture) {
		switch gesture.method {
		case let .tap(numberOfTaps: numberOfTaps):
			let gestureRecognizer = UITapGestureRecognizer(target: context.coordinator,
														   action: #selector(context.coordinator.captureGesture(_:)))
			gestureRecognizer.numberOfTapsRequired = numberOfTaps
			if numberOfTaps == 1 {
				// If a user double taps to zoom via the built in gesture, a normal
				// tap should not be triggered.
				if let doubleTapRecognizer = mapView.gestureRecognizers?
					.first(where: {
						$0 is UITapGestureRecognizer && ($0 as! UITapGestureRecognizer).numberOfTapsRequired == 2
					})
				{
					gestureRecognizer.require(toFail: doubleTapRecognizer)
				}
			}
			mapView.addGestureRecognizer(gestureRecognizer)
			gesture.gestureRecognizer = gestureRecognizer

		case let .longPress(minimumDuration: minimumDuration):
			let gestureRecognizer = UILongPressGestureRecognizer(target: context.coordinator,
																 action: #selector(context.coordinator
																	 .captureGesture(_:)))
			gestureRecognizer.minimumPressDuration = minimumDuration

			mapView.addGestureRecognizer(gestureRecognizer)
			gesture.gestureRecognizer = gestureRecognizer
		}
	}
	
	@MainActor func processGesture(_ mapView: MLNMapView, _ sender: UIGestureRecognizer) {
		guard let gesture = gestures.first(where: { $0.gestureRecognizer == sender }) else {
			assertionFailure("\(sender) is not a registered UIGestureRecongizer on the MapView")
			return
		}

		// Process the gesture into a context response.
		let context = processContextFromGesture(mapView, gesture: gesture, sender: sender)
		// Run the context through the gesture held on the MapView (emitting to the MapView modifier).
		switch gesture.onChange {
		case let .context(action):
			action(context)
		case let .feature(action, layers):
			let point = sender.location(in: sender.view)
			let features = mapView.visibleFeatures(at: point, styleLayerIdentifiers: layers)
			action(context, features)
		}
	}
	
	@MainActor func processContextFromGesture(_ mapView: MLNMapView, gesture: MapGesture,
											  sender: UIGestureRecognizing) -> MapGestureContext {
		// Build the context of the gesture's event.
		let point: CGPoint = switch gesture.method {
		case let .tap(numberOfTaps: numberOfTaps):
			// Calculate the CGPoint of the last gesture tap
			sender.location(ofTouch: numberOfTaps - 1, in: mapView)
		case .longPress:
			// Calculate the CGPoint of the long process gesture.
			sender.location(in: mapView)
		}

		return MapGestureContext(gestureMethod: gesture.method,
								 state: sender.state,
								 point: point,
								 coordinate: mapView.convert(point, toCoordinateFrom: mapView))
	}
}

public extension NavigationMapView {
	/// Perform an action when the map view has loaded its style and all locally added style definitions.
	///
	/// - Parameter perform: The action to perform with the loaded style.
	/// - Returns: The modified map view.
	func onStyleLoaded(_ perform: @escaping (MLNStyle) -> Void) -> NavigationMapView {
		var newMapView = self
		newMapView.onStyleLoaded = perform
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
	///     .mapViewModifier { mapView in
	///         mapView.showUserLocation = true
	///     }
	/// ```
	///
	func unsafeMapViewModifier(_ modifier: @escaping (MLNMapView) -> Void) -> NavigationMapView {
		var newMapView = self
		newMapView.unsafeMapViewModifier = modifier
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
						 onTapChanged: @escaping (MapGestureContext) -> Void) -> NavigationMapView
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
						 onTapChanged: @escaping (MapGestureContext, [any MLNFeature]) -> Void) -> NavigationMapView
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
							   onPressChanged: @escaping (MapGestureContext) -> Void) -> NavigationMapView
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
	func expandClustersOnTapping(clusteredLayers: [ClusterLayer]) -> NavigationMapView {
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

	func onMapViewPortUpdate(_ onViewPortChanged: @escaping (MapViewPort) -> Void) -> Self {
		var result = self
		result.onViewPortChanged = onViewPortChanged
		return result
	}
}


// MARK: - Private

private extension NavigationMapView {
	
	@MainActor func applyModifiers(_ mapView: MLNMapView, runUnsafe: Bool) {
		mapView.contentInset = mapViewContentInset

		// Assume all controls are hidden by default (so that an empty list returns a map with no controls)
		mapView.logoView.isHidden = true
		mapView.compassView.isHidden = true
		mapView.attributionButton.isHidden = true

		// Apply each control configuration
		for control in controls {
			control.configureMapView(mapView)
		}

		if runUnsafe {
			unsafeMapViewModifier?(mapView)
		}
	}
}
