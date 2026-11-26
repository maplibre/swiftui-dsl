import CoreLocation
import Foundation
import MapLibre
import Mockable
import SwiftUI
import Testing
@testable import MapLibreSwiftUI

@MainActor
struct MapCameraAnimationTests {
    /// Every camera factory must expose the same explicit animation choice.
    @Test(arguments: [true, false])
    func factoriesPreserveAnimationPreference(animated: Bool) {
        let coordinate = CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)
        let cameras: [MapViewCamera] = [
            .default(animated: animated),
            .center(coordinate, zoom: 12, animated: animated),
            .trackUserLocation(animated: animated),
            .trackUserLocationWithHeading(animated: animated),
            .trackUserLocationWithCourse(animated: animated),
            .boundingBox(MLNCoordinateBounds(sw: coordinate, ne: coordinate), animated: animated),
            .showcase(shapeCollection: MLNShapeCollection(shapes: []), animated: animated),
        ]
        #expect(cameras.allSatisfy { $0.animated == animated })
    }

    /// Existing factory calls keep Native animation enabled, and editing a camera retains the user's preference.
    @Test func defaultsAndCameraOperations() {
        #expect(MapViewCamera.default().animated)
        #expect(MapViewCamera.center(.init(latitude: 0, longitude: 0), zoom: 12).animated)
        #expect(MapViewCamera.trackUserLocation().animated)
        #expect(MapViewCamera.trackUserLocationWithHeading().animated)
        #expect(MapViewCamera.trackUserLocationWithCourse().animated)
        #expect(MapViewCamera.boundingBox(.init()).animated)
        #expect(MapViewCamera.showcase(shapeCollection: MLNShapeCollection(shapes: [])).animated)

        var camera = MapViewCamera.default(animated: false)
        camera.setZoom(14)
        camera.setPitch(30)
        #expect(!camera.animated)
        camera.pan(.right)
        #expect(!camera.animated)
    }

    /// The choice must reach Native for a loaded map, while initial positioning must never animate.
    @Test(arguments: [true, false], [true, false])
    func forwardsNativeAnimationPreference(animated: Bool, allowsAnimation: Bool) async throws {
        let fixture = Fixture()
        let camera = MapViewCamera.center(.init(latitude: 40.7128, longitude: -74.0060), zoom: 12, animated: animated)
        try await fixture.apply(camera, allowsAnimation: allowsAnimation)
        verify(fixture.map).setCamera(.any, animated: .value(animated && allowsAnimation)).called(1)
        verify(fixture.map).setCamera(.any, animated: .value(!(animated && allowsAnimation))).called(0)
    }

    /// Toggling the preference alone must not recenter the map, but the next position change must honor it.
    @Test func preferenceOnlyChangeDoesNotMoveCamera() async throws {
        let fixture = Fixture()
        var camera = MapViewCamera.default()
        try await fixture.apply(camera)
        camera.animated = false
        fixture.coordinator.applyCameraChangeFromStateUpdate(fixture.map, camera: camera)
        #expect(fixture.coordinator.cameraUpdateTask == nil)
        verify(fixture.map).setCamera(.any, animated: .any).called(1)

        camera.setZoom(14)
        try await fixture.apply(camera)
        verify(fixture.map).setCamera(.any, animated: .value(false)).called(1)
    }

    /// Reading the user's new viewport back into the binding must not reset its animation preference.
    @Test(arguments: [true, false])
    func gesturesRetainAnimationPreference(animated: Bool) async throws {
        let fixture = Fixture()
        fixture.value.camera.animated = animated
        fixture.coordinator.applyCameraChangeFromGesture(fixture.map, reason: .gesturePan)
        try await fixture.finishUpdate()
        #expect(fixture.value.camera.animated == animated)
        #expect(fixture.value.camera.lastReasonForChange == .gesturePan)
    }

    @MainActor
    private final class CameraValue {
        var camera = MapViewCamera.default()
    }

    @MainActor
    private final class Fixture {
        let map = MockMLNMapViewRepresentable()
        let value = CameraValue()
        let coordinator: MapViewCoordinator<MLNMapViewController>

        init() {
            let value = value
            let view = MapView(
                styleURL: URL(fileURLWithPath: "/unused-style.json"),
                camera: Binding(get: { value.camera }, set: { value.camera = $0 })
            )
            coordinator = MapViewCoordinator(
                parent: view,
                onGesture: { _, _ in },
                onViewProxyChanged: { _ in },
                proxyUpdateMode: .onFinish
            )
            given(map).frame.willReturn(CGRect(x: 0, y: 0, width: 320, height: 640))
            given(map).contentInset.willReturn(.zero)
            given(map).camera.willReturn(MLNMapCamera())
            given(map).setCamera(.any, animated: .any).willReturn()
            given(map).centerCoordinate.willReturn(.init(latitude: 40.7128, longitude: -74.0060))
            given(map).zoomLevel.willReturn(12)
            given(map).direction.willReturn(0)
            given(map).minimumPitch.willReturn(0)
            given(map).maximumPitch.willReturn(60)
        }

        func apply(_ camera: MapViewCamera, allowsAnimation: Bool = true) async throws {
            value.camera = camera
            coordinator.applyCameraChangeFromStateUpdate(map, camera: camera, animated: allowsAnimation)
            try await finishUpdate()
        }

        func finishUpdate() async throws {
            // Keep the timeout monotonic without requiring iOS 16's Clock APIs.
            let deadline = ProcessInfo.processInfo.systemUptime + 1
            while coordinator.cameraUpdateContinuation == nil, ProcessInfo.processInfo.systemUptime < deadline {
                try await Task.sleep(nanoseconds: 5_000_000)
            }
            let continuation = try #require(coordinator.cameraUpdateContinuation)
            let task = coordinator.cameraUpdateTask
            coordinator.cameraUpdateContinuation = nil
            coordinator.cameraUpdateTask = nil
            continuation.resume()
            await task?.value
        }
    }
}
