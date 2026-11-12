import CoreLocation
import MapLibre
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

    @MainActor func testReframingReappliesUnchangedCamera() async throws {
        let coordinate = CLLocationCoordinate2D(latitude: 45.0, longitude: -127.0)
        let camera: MapViewCamera = .center(coordinate, zoom: 10)

        given(maplibreMapView)
            .setCenter(.any, zoomLevel: .any, direction: .any, animated: .any)
            .willReturn()

        try await simulateCameraUpdateAndWait {
            self.coordinator.applyCameraChangeFromStateUpdate(
                self.maplibreMapView, camera: camera, animated: false
            )
        }

        try await simulateCameraUpdateAndWait {
            self.coordinator.applyCameraChangeFromStateUpdate(
                self.maplibreMapView, camera: camera, animated: false, reframing: true
            )
        }

        verify(maplibreMapView)
            .setCenter(.value(coordinate), zoomLevel: .value(10), direction: .value(0), animated: .value(false))
            .called(2)
    }

    @MainActor func testReframingSkipsCameraAlreadyTracking() async throws {
        let camera: MapViewCamera = .trackUserLocation()

        given(maplibreMapView)
            .userTrackingMode.willReturn(.follow)

        try await simulateCameraUpdateAndWait {
            self.coordinator.applyCameraChangeFromStateUpdate(
                self.maplibreMapView, camera: camera, animated: false
            )
        }

        coordinator.applyCameraChangeFromStateUpdate(
            maplibreMapView, camera: camera, animated: false, reframing: true
        )

        verify(maplibreMapView)
            .userTrackingMode(newValue: .value(.follow))
            .setCalled(1)
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

    @MainActor func testShowcaseCameraUpdate() async throws {
        let coordinates = [
            CLLocationCoordinate2D(latitude: 45.0, longitude: -127.0),
            CLLocationCoordinate2D(latitude: 45.2, longitude: -127.3),
        ]
        let shapeCollection = MLNShapeCollection(shapes: [MLNPolylineFeature(coordinates: coordinates)])
        let contentInset = UIEdgeInsets(top: 11, left: 22, bottom: 33, right: 44)
        let newCamera: MapViewCamera = .showcase(shapeCollection: shapeCollection, edgePadding: contentInset)
        let fittedCamera = MLNMapCamera()

        given(maplibreMapView)
            .cameraThatFitsShape(
                .any,
                direction: .any,
                edgePadding: .any
            )
            .willReturn(fittedCamera)

        given(maplibreMapView)
            .setCamera(.any, animated: .any)
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
            .minimumPitch(newValue: .value(0))
            .setCalled(1)

        verify(maplibreMapView)
            .maximumPitch(newValue: .value(0))
            .setCalled(1)

        verify(maplibreMapView)
            .direction(newValue: .value(0))
            .setCalled(1)

        verify(maplibreMapView)
            .cameraThatFitsShape(
                .any,
                direction: .value(0),
                edgePadding: .value(contentInset)
            )
            .called(1)

        verify(maplibreMapView)
            .setCamera(.any, animated: .value(false))
            .called(1)

        verify(maplibreMapView)
            .setVisibleCoordinateBounds(
                .any,
                edgePadding: .any,
                animated: .any,
                completionHandler: .any
            )
            .called(0)
    }

    @MainActor func testShowcaseUnchangedCameraSkipsSecondUpdate() async throws {
        let coordinates = [
            CLLocationCoordinate2D(latitude: 45.0, longitude: -127.0),
            CLLocationCoordinate2D(latitude: 45.2, longitude: -127.3),
        ]
        let shapeCollection = MLNShapeCollection(shapes: [MLNPolylineFeature(coordinates: coordinates)])
        let camera: MapViewCamera = .showcase(shapeCollection: shapeCollection)
        let fittedCamera = MLNMapCamera()

        given(maplibreMapView)
            .cameraThatFitsShape(
                .any,
                direction: .any,
                edgePadding: .any
            )
            .willReturn(fittedCamera)

        given(maplibreMapView)
            .setCamera(.any, animated: .any)
            .willReturn()

        try await simulateCameraUpdateAndWait {
            self.coordinator.applyCameraChangeFromStateUpdate(
                self.maplibreMapView, camera: camera, animated: false
            )
        }

        coordinator.applyCameraChangeFromStateUpdate(
            maplibreMapView, camera: camera, animated: false
        )

        verify(maplibreMapView)
            .cameraThatFitsShape(.any, direction: .any, edgePadding: .any)
            .called(1)

        verify(maplibreMapView)
            .setCamera(.any, animated: .any)
            .called(1)
    }

    @MainActor
    private func simulateCameraUpdateAndWait(action: @escaping () -> Void) async throws {
        // Stage 1: Execute camera action and wait for continuation wiring.
        action()

        let pollIntervalNs = 100 * NSEC_PER_MSEC
        let continuationTimeoutNs = 500 * NSEC_PER_MSEC
        var waitedNs: UInt64 = 0

        while coordinator.cameraUpdateContinuation == nil && waitedNs < continuationTimeoutNs {
            try await Task.sleep(nanoseconds: pollIntervalNs)
            waitedNs += UInt64(pollIntervalNs)
        }

        guard let continuation = coordinator.cameraUpdateContinuation else {
            XCTFail("Stage 1 timeout: cameraUpdateContinuation was never set")
            return
        }

        // Stage 2: Resume continuation, as mapViewDidBecomeIdle does, and verify cameraUpdateTask completes.
        continuation.resume(returning: ())
        coordinator.cameraUpdateContinuation = nil

        let taskCompletionExpectation = XCTestExpectation(
            description: "Stage 2: cameraUpdateTask completes after continuation resume"
        )

        Task { @MainActor in
            _ = await coordinator.cameraUpdateTask?.value
            taskCompletionExpectation.fulfill()
        }

        await fulfillment(of: [taskCompletionExpectation], timeout: 1.0)
    }
}
