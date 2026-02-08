import CarPlay
import CoreLocation
import MapLibre
import Mockable
import Numerics
import SnapshotTesting
import Testing
@testable import MapLibreSwiftUI

@MainActor
struct MapViewCameraOperationTests {
    // MARK: - Test Data

    let maplibreMapView = MockMLNMapViewRepresentable()
    let testCoordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    let testZoom: Double = 15.0
    let testPitch: Double = 30.0
    let testDirection: Double = 90.0
    let testPitchRange: CameraPitchRange = .freeWithinRange(minimum: 0, maximum: 60)

    var mockProxy: MapViewProxy {
        MapViewProxy(
            mapView: maplibreMapView,
            lastReasonForChange: .programmatic
        )
    }

    init() {
        given(maplibreMapView)
            .centerCoordinate
            .willReturn(testCoordinate)

        given(maplibreMapView)
            .zoomLevel
            .willReturn(testZoom)

        given(maplibreMapView)
            .direction
            .willReturn(testDirection)
    }

    // MARK: - setZoom Tests

    @Test func setZoom_centeredCamera_updatesZoomCorrectly() {
        var camera = MapViewCamera.center(
            testCoordinate,
            zoom: 10.0,
            pitch: testPitch,
            pitchRange: testPitchRange,
            direction: testDirection
        )

        camera.setZoom(testZoom)

        assertSnapshot(of: camera.state, as: .dump)
        #expect(camera.lastReasonForChange == .programmatic)
    }

    @Test func setZoom_trackingUserLocationCamera_updatesZoomCorrectly() {
        var camera = MapViewCamera.trackUserLocation(
            zoom: 10.0,
            pitch: testPitch,
            pitchRange: testPitchRange,
            direction: testDirection
        )

        camera.setZoom(testZoom)

        assertSnapshot(of: camera.state, as: .dump)
        #expect(camera.lastReasonForChange == .programmatic)
    }

    @Test func setZoom_trackingUserLocationWithHeadingCamera_updatesZoomCorrectly() {
        var camera = MapViewCamera.trackUserLocationWithHeading(
            zoom: 10.0,
            pitch: testPitch,
            pitchRange: testPitchRange
        )

        camera.setZoom(testZoom)

        assertSnapshot(of: camera.state, as: .dump)
        #expect(camera.lastReasonForChange == .programmatic)
    }

    @Test func setZoom_trackingUserLocationWithCourseCamera_updatesZoomCorrectly() {
        var camera = MapViewCamera.trackUserLocationWithCourse(
            zoom: 10.0,
            pitch: testPitch,
            pitchRange: testPitchRange
        )

        camera.setZoom(testZoom)

        assertSnapshot(of: camera.state, as: .dump)
        #expect(camera.lastReasonForChange == .programmatic)
    }

    @Test func setZoom_rectCamera_withProxy_convertsToCenteredCamera() {
        let bounds = MLNCoordinateBounds(
            sw: CLLocationCoordinate2D(latitude: 37.0, longitude: -123.0),
            ne: CLLocationCoordinate2D(latitude: 38.0, longitude: -122.0)
        )
        var camera = MapViewCamera.boundingBox(bounds)

        camera.setZoom(testZoom, proxy: mockProxy)

        assertSnapshot(of: camera.state, as: .dump)
        #expect(camera.lastReasonForChange == .programmatic)
    }

    @Test func setZoom_rectCamera_withoutProxy_doesNothing() {
        let bounds = MLNCoordinateBounds(
            sw: CLLocationCoordinate2D(latitude: 37.0, longitude: -123.0),
            ne: CLLocationCoordinate2D(latitude: 38.0, longitude: -122.0)
        )
        var camera = MapViewCamera.boundingBox(bounds)
        let originalState = camera.state

        camera.setZoom(testZoom)

        #expect(camera.state == originalState)
        #expect(camera.lastReasonForChange == .programmatic) // Still set from constructor
    }

    // MARK: - incrementZoom Tests

    @Test func incrementZoom_centeredCamera_incrementsZoomCorrectly() {
        var camera = MapViewCamera.center(
            testCoordinate,
            zoom: 10.0,
            pitch: testPitch,
            pitchRange: testPitchRange,
            direction: testDirection
        )

        camera.incrementZoom(by: 2.5)

        assertSnapshot(of: camera.state, as: .dump)
        #expect(camera.lastReasonForChange == .programmatic)
    }

    @Test func incrementZoom_negativeIncrement_decrementsZoom() {
        var camera = MapViewCamera.center(testCoordinate, zoom: 10.0)

        camera.incrementZoom(by: -3.0)

        assertSnapshot(of: camera.state, as: .dump)
    }

    @Test func incrementZoom_trackingUserLocationCamera_incrementsZoomCorrectly() {
        var camera = MapViewCamera.trackUserLocation(
            zoom: 8.0,
            pitch: testPitch,
            pitchRange: testPitchRange,
            direction: testDirection
        )

        camera.incrementZoom(by: 5.0)

        assertSnapshot(of: camera.state, as: .dump)
    }

    @Test func incrementZoom_trackingUserLocationWithHeadingCamera_incrementsZoomCorrectly() {
        var camera = MapViewCamera.trackUserLocationWithHeading(
            zoom: 12.0,
            pitch: testPitch,
            pitchRange: testPitchRange
        )

        camera.incrementZoom(by: -2.0)

        assertSnapshot(of: camera.state, as: .dump)
    }

    @Test func incrementZoom_trackingUserLocationWithCourseCamera_incrementsZoomCorrectly() {
        var camera = MapViewCamera.trackUserLocationWithCourse(
            zoom: 14.0,
            pitch: testPitch,
            pitchRange: testPitchRange
        )

        camera.incrementZoom(by: 1.5)

        assertSnapshot(of: camera.state, as: .dump)
    }

    @Test func incrementZoom_rectCamera_withProxy_convertsToCenteredCamera() {
        let bounds = MLNCoordinateBounds(
            sw: CLLocationCoordinate2D(latitude: 37.0, longitude: -123.0),
            ne: CLLocationCoordinate2D(latitude: 38.0, longitude: -122.0)
        )
        var camera = MapViewCamera.boundingBox(bounds)

        camera.incrementZoom(by: 3.0, proxy: mockProxy)

        assertSnapshot(of: camera.state, as: .dump)
    }

    @Test func incrementZoom_rectCamera_withoutProxy_doesNothing() {
        let bounds = MLNCoordinateBounds(
            sw: CLLocationCoordinate2D(latitude: 37.0, longitude: -123.0),
            ne: CLLocationCoordinate2D(latitude: 38.0, longitude: -122.0)
        )
        var camera = MapViewCamera.boundingBox(bounds)
        let originalState = camera.state

        camera.incrementZoom(by: 3.0)

        #expect(camera.state == originalState)
    }

    // MARK: - setPitch Tests

    @Test func setPitch_centeredCamera_updatesPitchCorrectly() {
        var camera = MapViewCamera.center(
            testCoordinate,
            zoom: testZoom,
            pitch: 0.0,
            pitchRange: testPitchRange,
            direction: testDirection
        )

        camera.setPitch(testPitch)

        assertSnapshot(of: camera.state, as: .dump)
        #expect(camera.lastReasonForChange == .programmatic)
    }

    @Test func setPitch_trackingUserLocationCamera_updatesPitchCorrectly() {
        var camera = MapViewCamera.trackUserLocation(
            zoom: testZoom,
            pitch: 0.0,
            pitchRange: testPitchRange,
            direction: testDirection
        )

        camera.setPitch(testPitch)

        assertSnapshot(of: camera.state, as: .dump)
    }

    @Test func setPitch_trackingUserLocationWithHeadingCamera_updatesPitchCorrectly() {
        var camera = MapViewCamera.trackUserLocationWithHeading(
            zoom: testZoom,
            pitch: 0.0,
            pitchRange: testPitchRange
        )

        camera.setPitch(testPitch)

        assertSnapshot(of: camera.state, as: .dump)
    }

    @Test func setPitch_trackingUserLocationWithCourseCamera_updatesPitchCorrectly() {
        var camera = MapViewCamera.trackUserLocationWithCourse(
            zoom: testZoom,
            pitch: 0.0,
            pitchRange: testPitchRange
        )

        camera.setPitch(testPitch)

        assertSnapshot(of: camera.state, as: .dump)
    }

    @Test func setPitch_rectCamera_withProxy_convertsToCenteredCamera() {
        let bounds = MLNCoordinateBounds(
            sw: CLLocationCoordinate2D(latitude: 37.0, longitude: -123.0),
            ne: CLLocationCoordinate2D(latitude: 38.0, longitude: -122.0)
        )
        var camera = MapViewCamera.boundingBox(bounds)

        camera.setPitch(testPitch, proxy: mockProxy)

        assertSnapshot(of: camera.state, as: .dump)
    }

    @Test func setPitch_rectCamera_withoutProxy_doesNothing() {
        let bounds = MLNCoordinateBounds(
            sw: CLLocationCoordinate2D(latitude: 37.0, longitude: -123.0),
            ne: CLLocationCoordinate2D(latitude: 38.0, longitude: -122.0)
        )
        var camera = MapViewCamera.boundingBox(bounds)
        let originalState = camera.state

        camera.setPitch(testPitch)

        #expect(camera.state == originalState)
    }

    // MARK: - setDirection Tests

    @Test func setDirection_centeredCamera_updatesDirectionCorrectly() {
        var camera = MapViewCamera.center(
            testCoordinate,
            zoom: testZoom,
            pitch: testPitch,
            pitchRange: testPitchRange,
            direction: 0.0
        )

        camera.setDirection(testDirection)

        assertSnapshot(of: camera.state, as: .dump)
        #expect(camera.lastReasonForChange == .programmatic)
    }

    @Test func setDirection_trackingUserLocationCamera_updatesDirectionCorrectly() {
        var camera = MapViewCamera.trackUserLocation(
            zoom: testZoom,
            pitch: testPitch,
            pitchRange: testPitchRange,
            direction: 0.0
        )

        camera.setDirection(testDirection)

        assertSnapshot(of: camera.state, as: .dump)
    }

    @Test func setDirection_trackingUserLocationWithHeadingCamera_ignoresDirection() {
        var camera = MapViewCamera.trackUserLocationWithHeading(
            zoom: testZoom,
            pitch: testPitch,
            pitchRange: testPitchRange
        )
        let originalState = camera.state

        camera.setDirection(testDirection)

        // Should remain unchanged for heading tracking
        #expect(camera.state == originalState)
    }

    @Test func setDirection_trackingUserLocationWithCourseCamera_ignoresDirection() {
        var camera = MapViewCamera.trackUserLocationWithCourse(
            zoom: testZoom,
            pitch: testPitch,
            pitchRange: testPitchRange
        )
        let originalState = camera.state

        camera.setDirection(testDirection)

        // Should remain unchanged for course tracking
        #expect(camera.state == originalState)
    }

    @Test func setDirection_rectCamera_withProxy_convertsToCenteredCamera() {
        let bounds = MLNCoordinateBounds(
            sw: CLLocationCoordinate2D(latitude: 37.0, longitude: -123.0),
            ne: CLLocationCoordinate2D(latitude: 38.0, longitude: -122.0)
        )
        var camera = MapViewCamera.boundingBox(bounds)

        camera.setDirection(testDirection, proxy: mockProxy)

        assertSnapshot(of: camera.state, as: .dump)
    }

    @Test func setDirection_rectCamera_withoutProxy_doesNothing() {
        let bounds = MLNCoordinateBounds(
            sw: CLLocationCoordinate2D(latitude: 37.0, longitude: -123.0),
            ne: CLLocationCoordinate2D(latitude: 38.0, longitude: -122.0)
        )
        var camera = MapViewCamera.boundingBox(bounds)
        let originalState = camera.state

        camera.setDirection(testDirection)

        #expect(camera.state == originalState)
    }

    // MARK: - CarPlay Pan Tests

    @Test func pan_centeredCamera_upDirection_pansCameraUp() {
        var camera = MapViewCamera.center(testCoordinate, zoom: testZoom)

        camera.pan(.up)

        assertSnapshot(of: camera.state, as: .dump)

        // Verify the camera moved north (increased latitude)
        if case let .centered(onCoordinate: newCoordinate, _, _, _, _) = camera.state {
            #expect(newCoordinate.latitude > testCoordinate.latitude)
            #expect(newCoordinate.longitude == testCoordinate.longitude)
        }
    }

    @Test func pan_centeredCamera_downDirection_pansCameraDown() {
        var camera = MapViewCamera.center(testCoordinate, zoom: testZoom)

        camera.pan(.down)

        assertSnapshot(of: camera.state, as: .dump)

        // Verify the camera moved south (decreased latitude)
        if case let .centered(onCoordinate: newCoordinate, _, _, _, _) = camera.state {
            #expect(newCoordinate.latitude < testCoordinate.latitude)
            #expect(newCoordinate.longitude == testCoordinate.longitude)
        }
    }

    @Test func pan_centeredCamera_leftDirection_pansCameraLeft() {
        var camera = MapViewCamera.center(testCoordinate, zoom: testZoom)

        camera.pan(.left)

        assertSnapshot(of: camera.state, as: .dump)

        // Verify the camera moved west (decreased longitude)
        if case let .centered(onCoordinate: newCoordinate, _, _, _, _) = camera.state {
            #expect(newCoordinate.latitude == testCoordinate.latitude)
            #expect(newCoordinate.longitude < testCoordinate.longitude)
        }
    }

    @Test func pan_centeredCamera_rightDirection_pansCameraRight() {
        var camera = MapViewCamera.center(testCoordinate, zoom: testZoom)

        camera.pan(.right)

        assertSnapshot(of: camera.state, as: .dump)

        // Verify the camera moved east (increased longitude)
        if case let .centered(onCoordinate: newCoordinate, _, _, _, _) = camera.state {
            #expect(newCoordinate.latitude == testCoordinate.latitude)
            #expect(newCoordinate.longitude > testCoordinate.longitude)
        }
    }

    @Test func pan_trackingUserLocationCamera_convertsToCenteredCamera() {
        var camera = MapViewCamera.trackUserLocation(zoom: testZoom)

        camera.pan(.up, proxy: mockProxy)

        assertSnapshot(of: camera.state, as: .dump)

        // Should convert to centered camera
        if case .centered = camera.state {
            // Expected behavior
        } else {
            Issue.record("Expected camera to convert to centered state")
        }
    }

    @Test func pan_trackingUserLocationWithHeadingCamera_convertsToCenteredCamera() {
        var camera = MapViewCamera.trackUserLocationWithHeading(zoom: testZoom)

        camera.pan(.down, proxy: mockProxy)

        assertSnapshot(of: camera.state, as: .dump)

        // Should convert to centered camera
        if case .centered = camera.state {
            // Expected behavior
        } else {
            Issue.record("Expected camera to convert to centered state")
        }
    }

    @Test func pan_trackingUserLocationWithCourseCamera_convertsToCenteredCamera() {
        var camera = MapViewCamera.trackUserLocationWithCourse(zoom: testZoom)

        camera.pan(.left, proxy: mockProxy)

        assertSnapshot(of: camera.state, as: .dump)

        // Should convert to centered camera
        if case .centered = camera.state {
            // Expected behavior
        } else {
            Issue.record("Expected camera to convert to centered state")
        }
    }

    @Test func pan_rectCamera_withProxy_convertsToCenteredCamera() {
        let bounds = MLNCoordinateBounds(
            sw: CLLocationCoordinate2D(latitude: 37.0, longitude: -123.0),
            ne: CLLocationCoordinate2D(latitude: 38.0, longitude: -122.0)
        )
        var camera = MapViewCamera.boundingBox(bounds)

        camera.pan(.right, proxy: mockProxy)

        assertSnapshot(of: camera.state, as: .dump)

        // Should convert to centered camera
        if case .centered = camera.state {
            // Expected behavior
        } else {
            Issue.record("Expected camera to convert to centered state")
        }
    }

    @Test func pan_rectCamera_withoutProxy_usesDefaults() {
        let bounds = MLNCoordinateBounds(
            sw: CLLocationCoordinate2D(latitude: 37.0, longitude: -123.0),
            ne: CLLocationCoordinate2D(latitude: 38.0, longitude: -122.0)
        )
        var camera = MapViewCamera.boundingBox(bounds)

        camera.pan(.up)

        assertSnapshot(of: camera.state, as: .dump)

        // Should convert to centered camera using defaults
        if case let .centered(onCoordinate: coordinate, zoom: zoom, _, _, _) = camera.state {
            #expect(coordinate.latitude.isApproximatelyEqual(
                to: MapViewCamera.Defaults.coordinate.latitude,
                absoluteTolerance: 0.05
            ))
            #expect(coordinate.longitude.isApproximatelyEqual(
                to: MapViewCamera.Defaults.coordinate.longitude,
                absoluteTolerance: 0.05
            ))
            #expect(zoom == MapViewCamera.Defaults.zoom)
        } else {
            Issue.record("Expected camera to convert to centered state with defaults")
        }
    }

    @Test func pan_zoomSensitivity_higherZoomMeansSmallerMovement() {
        let highZoomCamera = MapViewCamera.center(testCoordinate, zoom: 20.0)
        let lowZoomCamera = MapViewCamera.center(testCoordinate, zoom: 5.0)

        var highZoomCameraCopy = highZoomCamera
        var lowZoomCameraCopy = lowZoomCamera

        highZoomCameraCopy.pan(.up)
        lowZoomCameraCopy.pan(.up)

        // Get the new coordinates
        guard case let .centered(onCoordinate: highZoomCoord, _, _, _, _) = highZoomCameraCopy.state,
              case let .centered(onCoordinate: lowZoomCoord, _, _, _, _) = lowZoomCameraCopy.state
        else {
            Issue.record("Expected centered camera states")
            return
        }

        let highZoomDelta = highZoomCoord.latitude - testCoordinate.latitude
        let lowZoomDelta = lowZoomCoord.latitude - testCoordinate.latitude

        // Higher zoom should result in smaller movement
        #expect(highZoomDelta < lowZoomDelta)
        #expect(highZoomDelta > 0) // Still moved north
        #expect(lowZoomDelta > 0) // Still moved north
    }
}
