import MapLibre
import SwiftUI

@MainActor
final class MapViewGestureManager {
    private(set) var gestures: [MapGesture] = []
    var onGestureChange: (([MapGesture]) -> Void)?

    let isDefault: Bool

    init(isDefault: Bool = false) {
        self.isDefault = isDefault
    }

    func register(_ gesture: MapGesture) {
        gestures.append(gesture)
        onGestureChange?(gestures)
    }

    func remove(_ gesture: MapGesture) {
        guard let index = gestures.firstIndex(of: gesture) else { return }
        gestures.remove(at: index)
        onGestureChange?(gestures)
    }
}

#if swift(>=6.2)
    private struct OnMapGestureKey: @MainActor EnvironmentKey {
        @MainActor static let defaultValue = MapViewGestureManager(isDefault: true)
    }
#else
    private struct OnMapGestureKey: EnvironmentKey {
        static let defaultValue = MapViewGestureManager(isDefault: true)
    }
#endif

@MainActor
extension EnvironmentValues {
    var onMapGestures: MapViewGestureManager {
        get { self[OnMapGestureKey.self] }
        set { self[OnMapGestureKey.self] = newValue }
    }
}

private struct ScopedGestureView<Content: View>: View {
    let content: Content
    let gesture: MapGesture

    /// This manager will be either the SwiftUI global default OR
    /// A local manager scoped to a view above this view modifiers caller.
    ///
    /// See logic in body.
    @Environment(\.onMapGestures) var parentManager

    /// This manager will only be be injected and used if the parent manager is the global
    /// static default.
    @State private var localManager = MapViewGestureManager()

    var body: some View {
        // If the manager is default, we need to create a new local manager.
        // This ensures the top level caller in a View hierarchy generates a
        // new manager.
        //
        // If the manager is a local manager, we'll skip to else and use it.
        if parentManager.isDefault {
            content
                // Apply the new local context as top level parent.
                .environment(\.onMapGestures, localManager)
                .onAppear {
                    localManager.register(gesture)
                }
                .onDisappear {
                    localManager.remove(gesture)
                }
        } else {
            content
                .onAppear {
                    parentManager.register(gesture)
                }
                .onDisappear {
                    parentManager.remove(gesture)
                }
        }
    }
}

private struct OnMapGesturesViewModifier: ViewModifier {
    let gesture: MapGesture

    func body(content: Content) -> some View {
        ScopedGestureView(content: content, gesture: gesture)
    }
}

public extension View {
    /// Add an tap gesture handler to the MapView
    ///
    /// - Parameters:
    ///   - count: The number of taps required to run the gesture.
    ///   - onTapChanged: Emits the context whenever the gesture changes (e.g. began, ended, etc), that also contains
    /// information like the latitude and longitude of the tap.
    func onTapMapGesture(
        count: Int = 1,
        onTapChanged: @escaping (MapGestureContext) -> Void
    ) -> some View {
        // Build the gesture and link it to the map view.
        let gesture = MapGesture(method: .tap(numberOfTaps: count),
                                 onChange: .context(onTapChanged))

        return modifier(OnMapGesturesViewModifier(gesture: gesture))
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
    func onTapMapGesture(
        count: Int = 1,
        on layers: Set<String>?,
        onTapChanged: @escaping (MapGestureContext, [any MLNFeature]) -> Void
    ) -> some View {
        // Build the gesture and link it to the map view.
        let gesture = MapGesture(method: .tap(numberOfTaps: count),
                                 onChange: .feature(onTapChanged, layers: layers))
        return modifier(OnMapGesturesViewModifier(gesture: gesture))
    }

    /// Add a long press gesture handler to the MapView
    ///
    /// - Parameters:
    ///   - minimumDuration: The minimum duration in seconds the user must press the screen to run the gesture.
    ///   - onPressChanged: Emits the context whenever the gesture changes (e.g. began, ended, etc).
    func onLongPressMapGesture(
        minimumDuration: Double = 0.5,
        onPressChanged: @escaping (MapGestureContext) -> Void
    ) -> some View {
        // Build the gesture and link it to the map view.
        let gesture = MapGesture(method: .longPress(minimumDuration: minimumDuration),
                                 onChange: .context(onPressChanged))

        return modifier(OnMapGesturesViewModifier(gesture: gesture))
    }
}
