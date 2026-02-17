import Testing
@testable import MapLibreSwiftUI

@MainActor
struct TestGestureManager {
    @Test("Gesture manager lifecycle")
    func registerAndRemove() {
        let manager = MapViewGestureManager()
        let gesture = MapGesture(
            method: .tap(numberOfTaps: 1),
            onChange: .context { _ in }
        )

        manager.register(gesture)
        #expect(manager.gestures.first == gesture)

        manager.remove(gesture)
        #expect(manager.gestures.isEmpty)
    }
}
