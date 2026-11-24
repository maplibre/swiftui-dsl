import CoreLocation
import MapLibre
import Mockable
import Testing
@testable import MapLibreSwiftUI

@MainActor
@Suite(.timeLimit(.minutes(1)))
struct MapViewCoordinatorCameraUpdateTests {
    private let maplibreMapView: MockMLNMapViewRepresentable
    private let coordinator: MapViewCoordinator<MLNMapViewController>

    init() {
        maplibreMapView = MockMLNMapViewRepresentable()
        given(maplibreMapView).frame.willReturn(.zero)
        coordinator = MapViewCoordinator(
            parent: MapView(styleURL: URL(string: "https://maplibre.org")!),
            onGesture: { _, _ in },
            onViewProxyChanged: { _ in },
            proxyUpdateMode: .onFinish
        )
    }

    @Test func reframingReappliesUnchangedCamera() async throws {
        let coordinate = CLLocationCoordinate2D(latitude: 45.0, longitude: -127.0)
        let camera: MapViewCamera = .center(coordinate, zoom: 10)

        given(maplibreMapView)
            .setCenter(.any, zoomLevel: .any, direction: .any, animated: .any)
            .willReturn()

        try await simulateCameraUpdateAndWait {
            coordinator.applyCameraChangeFromStateUpdate(
                maplibreMapView, camera: camera, animated: false
            )
        }

        try await simulateCameraUpdateAndWait {
            coordinator.applyCameraChangeFromStateUpdate(
                maplibreMapView, camera: camera, animated: false, reframing: true
            )
        }

        verify(maplibreMapView)
            .setCenter(.value(coordinate), zoomLevel: .value(10), direction: .value(0), animated: .value(false))
            .called(2)
    }

    @Test func reframingSkipsCameraAlreadyTracking() async throws {
        let camera: MapViewCamera = .trackUserLocation()

        given(maplibreMapView)
            .userTrackingMode.willReturn(.follow)

        try await simulateCameraUpdateAndWait {
            coordinator.applyCameraChangeFromStateUpdate(
                maplibreMapView, camera: camera, animated: false
            )
        }

        coordinator.applyCameraChangeFromStateUpdate(
            maplibreMapView, camera: camera, animated: false, reframing: true
        )

        verify(maplibreMapView)
            .userTrackingMode(newValue: .value(.follow))
            .setCalled(1)
    }

    @Test func cancelCameraUpdateResumesPendingContinuation() async throws {
        given(maplibreMapView)
            .setCenter(.any, zoomLevel: .any, direction: .any, animated: .any)
            .willReturn()

        coordinator.applyCameraChangeFromStateUpdate(
            maplibreMapView,
            camera: .center(CLLocationCoordinate2D(latitude: 45, longitude: -127), zoom: 10),
            animated: false
        )
        let task = try #require(coordinator.cameraUpdateTask)
        defer { coordinator.cancelCameraUpdate() }

        for _ in 0 ..< 50 {
            if coordinator.cameraUpdateContinuation != nil {
                break
            }
            try await Task.sleep(for: .milliseconds(10))
        }
        try #require(coordinator.cameraUpdateContinuation != nil)

        coordinator.cancelCameraUpdate()
        try await waitForCompletion(of: task)

        #expect(coordinator.cameraUpdateTask == nil)
        #expect(coordinator.cameraUpdateContinuation == nil)
    }

    @Test func cancelCameraUpdateBeforeTaskStartsCompletesTask() async throws {
        coordinator.applyCameraChangeFromStateUpdate(
            maplibreMapView,
            camera: .center(CLLocationCoordinate2D(latitude: 45, longitude: -127), zoom: 10),
            animated: false
        )
        let task = try #require(coordinator.cameraUpdateTask)
        defer { coordinator.cancelCameraUpdate() }

        coordinator.cancelCameraUpdate()
        try await waitForCompletion(of: task)

        #expect(coordinator.cameraUpdateContinuation == nil)
        verify(maplibreMapView)
            .setCenter(.any, zoomLevel: .any, direction: .any, animated: .any)
            .called(0)
    }

    private func waitForCompletion(of task: Task<Void, Never>) async throws {
        let completion = AsyncStream.makeStream(of: Void.self)
        Task {
            await task.value
            completion.continuation.yield(())
            completion.continuation.finish()
        }
        let timeout = Task {
            try await Task.sleep(for: .seconds(1))
            completion.continuation.finish()
        }
        defer {
            timeout.cancel()
            completion.continuation.finish()
        }
        var events = completion.stream.makeAsyncIterator()
        try #require(await events.next() != nil, "The camera update did not finish within one second.")
    }

    private func simulateCameraUpdateAndWait(action: () -> Void) async throws {
        action()
        let task = try #require(coordinator.cameraUpdateTask)
        defer { coordinator.cancelCameraUpdate() }
        for _ in 0 ..< 50 {
            if coordinator.cameraUpdateContinuation != nil {
                break
            }
            try await Task.sleep(for: .milliseconds(10))
        }
        let continuation = try #require(coordinator.cameraUpdateContinuation)
        coordinator.cameraUpdateContinuation = nil
        continuation.resume()
        try await waitForCompletion(of: task)
    }
}
