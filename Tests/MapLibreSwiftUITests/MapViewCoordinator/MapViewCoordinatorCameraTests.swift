import CoreLocation
import Mockable
import XCTest
@testable import MapLibreSwiftUI

final class MapViewCoordinatorCameraTests: XCTestCase {
    var maplibreMapView: MockMLNMapViewRepresentable!
    var mapView: MapView<MLNMapViewController>!
    var coordinator: MapView<MLNMapViewController>.Coordinator!

    @MainActor
    override func setUp() async throws {
        maplibreMapView = MockMLNMapViewRepresentable()
        given(maplibreMapView).frame.willReturn(.zero)
        mapView = MapView(styleURL: URL(string: "https://maplibre.org")!)
        coordinator = MapView.Coordinator(
            parent: mapView,
            onGesture: { _, _ in
                // No action
            },
            onViewProxyChanged: { _ in
                // No action
            }, proxyUpdateMode: .onFinish
        )
    }

    @MainActor func testUnchangedCamera() async throws {
        let coordinate = CLLocationCoordinate2D(latitude: 45.0, longitude: -127.0)
        let camera: MapViewCamera = .center(coordinate, zoom: 10)

        given(maplibreMapView)
            .setCenter(
                .any,
                zoomLevel: .any,
                direction: .any,
                animated: .any
            )
            .willReturn()

        try await simulateCameraUpdateAndWait {
            self.coordinator.applyCameraChangeFromStateUpdate(
                self.maplibreMapView, camera: camera, animated: false
            )
        }

        coordinator.applyCameraChangeFromStateUpdate(
            maplibreMapView, camera: camera, animated: false
        )

        // All of the actions only allow 1 count of set even though we've run the action twice.
        // This verifies the comment above.
        verify(maplibreMapView)
            .userTrackingMode(newValue: .value(.none))
            .setCalled(1)

        verify(maplibreMapView)
            .setCenter(
                .value(coordinate),
                zoomLevel: .value(10),
                direction: .value(0),
                animated: .value(false)
            )
            .called(1)

        // Due to the .frame == .zero workaround, min/max pitch setting is called twice, once to set the
        // pitch, and then once to set the actual range.
        verify(maplibreMapView)
            .minimumPitch(newValue: .value(0))
            .setCalled(2)

        verify(maplibreMapView)
            .maximumPitch(newValue: .value(0))
            .setCalled(1)

        verify(maplibreMapView)
            .maximumPitch(newValue: .value(60))
            .setCalled(1)

        verify(maplibreMapView)
            .setZoomLevel(.any, animated: .any)
            .called(0)
    }

    @MainActor func testCenterCameraUpdate() async throws {
        let coordinate = CLLocationCoordinate2D(latitude: 12.3, longitude: 23.4)
        let newCamera: MapViewCamera = .center(coordinate, zoom: 13)

        given(maplibreMapView)
            .setCenter(
                .any,
                zoomLevel: .any,
                direction: .any,
                animated: .any
            )
            .willReturn()

        try await simulateCameraUpdateAndWait {
            self.coordinator.applyCameraChangeFromStateUpdate(
                self.maplibreMapView, camera: newCamera, animated: false
            )
        }

        verify(maplibreMapView)
            .userTrackingMode(newValue: .value(.none))
            .setCalled(1)

        verify(maplibreMapView)
            .setCenter(
                .value(coordinate),
                zoomLevel: .value(13),
                direction: .value(0),
                animated: .value(false)
            )
            .called(1)

        // Due to the .frame == .zero workaround, min/max pitch setting is called twice, once to set the
        // pitch, and then once to set the actual range.
        verify(maplibreMapView)
            .minimumPitch(newValue: .value(0))
            .setCalled(2)

        verify(maplibreMapView)
            .maximumPitch(newValue: .value(0))
            .setCalled(1)

        verify(maplibreMapView)
            .maximumPitch(newValue: .value(60))
            .setCalled(1)

        verify(maplibreMapView)
            .setZoomLevel(.any, animated: .any)
            .called(0)
    }

    @MainActor func testUserTrackingCameraUpdate() async throws {
        let newCamera: MapViewCamera = .trackUserLocation()

        given(maplibreMapView)
            .setZoomLevel(.any, animated: .any)
            .willReturn()

        try await simulateCameraUpdateAndWait {
            self.coordinator.applyCameraChangeFromStateUpdate(
                self.maplibreMapView, camera: newCamera, animated: false
            )
        }

        verify(maplibreMapView)
            .userTrackingMode(newValue: .value(.follow))
            .setCalled(1)

        verify(maplibreMapView)
            .setCenter(
                .any,
                zoomLevel: .any,
                direction: .any,
                animated: .any
            )
            .called(0)

        // Due to the .frame == .zero workaround, min/max pitch setting is called twice, once to set the
        // pitch, and then once to set the actual range.
        verify(maplibreMapView)
            .minimumPitch(newValue: .value(0))
            .setCalled(2)

        verify(maplibreMapView)
            .maximumPitch(newValue: .value(0))
            .setCalled(1)

        verify(maplibreMapView)
            .maximumPitch(newValue: .value(60))
            .setCalled(1)

        verify(maplibreMapView)
            .zoomLevel(newValue: .value(10))
            .setCalled(1)
    }

    @MainActor func testUserTrackingWithCourseCameraUpdate() async throws {
        let newCamera: MapViewCamera = .trackUserLocationWithCourse()

        given(maplibreMapView)
            .setZoomLevel(.any, animated: .any)
            .willReturn()

        try await simulateCameraUpdateAndWait {
            self.coordinator.applyCameraChangeFromStateUpdate(
                self.maplibreMapView, camera: newCamera, animated: false
            )
        }

        verify(maplibreMapView)
            .userTrackingMode(newValue: .value(.followWithCourse))
            .setCalled(1)

        verify(maplibreMapView)
            .setCenter(
                .any,
                zoomLevel: .any,
                direction: .any,
                animated: .any
            )
            .called(0)

        // Due to the .frame == .zero workaround, min/max pitch setting is called twice, once to set the
        // pitch, and then once to set the actual range.
        verify(maplibreMapView)
            .minimumPitch(newValue: .value(0))
            .setCalled(2)

        verify(maplibreMapView)
            .maximumPitch(newValue: .value(0))
            .setCalled(1)

        verify(maplibreMapView)
            .maximumPitch(newValue: .value(60))
            .setCalled(1)

        verify(maplibreMapView)
            .zoomLevel(newValue: .value(10))
            .setCalled(1)
    }

    @MainActor func testUserTrackingWithHeadingUpdate() async throws {
        let newCamera: MapViewCamera = .trackUserLocationWithHeading()

        given(maplibreMapView)
            .setZoomLevel(.any, animated: .any)
            .willReturn()

        try await simulateCameraUpdateAndWait {
            self.coordinator.applyCameraChangeFromStateUpdate(
                self.maplibreMapView, camera: newCamera, animated: false
            )
        }

        verify(maplibreMapView)
            .userTrackingMode(newValue: .value(.followWithHeading))
            .setCalled(1)

        verify(maplibreMapView)
            .setCenter(
                .any,
                zoomLevel: .any,
                direction: .any,
                animated: .any
            )
            .called(0)

        // Due to the .frame == .zero workaround, min/max pitch setting is called twice, once to set the
        // pitch, and then once to set the actual range.
        verify(maplibreMapView)
            .minimumPitch(newValue: .value(0))
            .setCalled(2)

        verify(maplibreMapView)
            .maximumPitch(newValue: .value(0))
            .setCalled(1)

        verify(maplibreMapView)
            .maximumPitch(newValue: .value(60))
            .setCalled(1)

        verify(maplibreMapView)
            .zoomLevel(newValue: .value(10))
            .setCalled(1)
    }

    // TODO: Test Rect & Showcase once we build it!

    @MainActor
    private func simulateCameraUpdateAndWait(action: @escaping () -> Void) async throws {
        let expectation = XCTestExpectation(description: "Camera update completed")

        Task {
            // Execute the provided camera action
            action()

            // Simulate the map becoming idle after a short delay
            try await Task.sleep(nanoseconds: 100 * NSEC_PER_MSEC)
            coordinator.cameraUpdateContinuation?.resume(returning: ())

            // Wait for the update task to complete
            _ = await coordinator.cameraUpdateTask?.value

            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 1.0)
    }
}
