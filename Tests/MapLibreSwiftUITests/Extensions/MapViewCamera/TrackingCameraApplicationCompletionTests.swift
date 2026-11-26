import MapLibre
import Mockable
import Testing
@testable import MapLibreSwiftUI

@MainActor
struct TrackingCameraApplicationCompletionTests {
    let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)

    init() {
        given(map).frame.willReturn(CGRect(x: 0, y: 0, width: 320, height: 240))
        given(map).setUserTrackingMode(.any, animated: .any, completionHandler: .any)
            .willProduce { _, _, completion in completion?() }
    }

    @Test("When the follow transition finishes, location tracking applies the requested zoom")
    func followZoomOnCompletion() {
        given(map).userTrackingMode.willReturn(.follow)

        map.apply(camera: .trackUserLocation(zoom: 8), animated: true)

        verify(map).zoomLevel(newValue: .value(8)).setCalled(1)
    }

    @Test("When the follow transition finishes, a changed tracking mode prevents the zoom update")
    func skipChangedFollowMode() {
        given(map).userTrackingMode.willReturn(.none)

        map.apply(camera: .trackUserLocation(zoom: 8), animated: true)

        verify(map).zoomLevel(newValue: .any).setCalled(0)
    }

    @Test("When the heading transition finishes, heading tracking applies the requested zoom")
    func headingZoomOnCompletion() {
        given(map).userTrackingMode.willReturn(.followWithHeading)

        map.apply(camera: .trackUserLocationWithHeading(zoom: 8), animated: true)

        verify(map).zoomLevel(newValue: .value(8)).setCalled(1)
    }

    @Test("When the heading transition finishes, a changed tracking mode prevents the zoom update")
    func skipChangedHeadingMode() {
        given(map).userTrackingMode.willReturn(.none)

        map.apply(camera: .trackUserLocationWithHeading(zoom: 8), animated: true)

        verify(map).zoomLevel(newValue: .any).setCalled(0)
    }

    @Test("When the course transition finishes, course tracking applies the requested zoom")
    func courseZoomOnCompletion() {
        given(map).userTrackingMode.willReturn(.followWithCourse)

        map.apply(camera: .trackUserLocationWithCourse(zoom: 8), animated: true)

        verify(map).zoomLevel(newValue: .value(8)).setCalled(1)
    }

    @Test("When the course transition finishes, a changed tracking mode prevents the zoom update")
    func skipChangedCourseMode() {
        given(map).userTrackingMode.willReturn(.none)

        map.apply(camera: .trackUserLocationWithCourse(zoom: 8), animated: true)

        verify(map).zoomLevel(newValue: .any).setCalled(0)
    }

    @Test("When the follow transition finishes, location tracking applies the requested direction")
    func followDirectionOnCompletion() {
        given(map).userTrackingMode.willReturn(.follow)

        map.apply(camera: .trackUserLocation(zoom: 8, direction: 82), animated: true)

        verify(map).direction(newValue: .value(82)).setCalled(1)
    }

    @Test("When the follow transition finishes, location tracking restores the requested minimum pitch")
    func followMinimumPitch() {
        given(map).userTrackingMode.willReturn(.follow)
        let camera = MapViewCamera.trackUserLocation(
            zoom: 8,
            pitch: 30,
            pitchRange: .freeWithinRange(minimum: 5, maximum: 45)
        )

        map.apply(camera: camera, animated: true)

        verify(map).minimumPitch(newValue: .value(5)).setCalled(1)
    }

    @Test("When the follow transition finishes, location tracking restores the requested maximum pitch")
    func followMaximumPitch() {
        given(map).userTrackingMode.willReturn(.follow)
        let camera = MapViewCamera.trackUserLocation(
            zoom: 8,
            pitch: 30,
            pitchRange: .freeWithinRange(minimum: 5, maximum: 45)
        )

        map.apply(camera: camera, animated: true)

        verify(map).maximumPitch(newValue: .value(45)).setCalled(1)
    }

    @Test("When the heading transition finishes, heading tracking restores the requested minimum pitch")
    func headingMinimumPitch() {
        given(map).userTrackingMode.willReturn(.followWithHeading)
        let camera = MapViewCamera.trackUserLocationWithHeading(
            zoom: 8,
            pitch: 30,
            pitchRange: .freeWithinRange(minimum: 5, maximum: 45)
        )

        map.apply(camera: camera, animated: true)

        verify(map).minimumPitch(newValue: .value(5)).setCalled(1)
    }

    @Test("When the heading transition finishes, heading tracking restores the requested maximum pitch")
    func headingMaximumPitch() {
        given(map).userTrackingMode.willReturn(.followWithHeading)
        let camera = MapViewCamera.trackUserLocationWithHeading(
            zoom: 8,
            pitch: 30,
            pitchRange: .freeWithinRange(minimum: 5, maximum: 45)
        )

        map.apply(camera: camera, animated: true)

        verify(map).maximumPitch(newValue: .value(45)).setCalled(1)
    }

    @Test("When the course transition finishes, course tracking restores the requested minimum pitch")
    func courseMinimumPitch() {
        given(map).userTrackingMode.willReturn(.followWithCourse)
        let camera = MapViewCamera.trackUserLocationWithCourse(
            zoom: 8,
            pitch: 30,
            pitchRange: .freeWithinRange(minimum: 5, maximum: 45)
        )

        map.apply(camera: camera, animated: true)

        verify(map).minimumPitch(newValue: .value(5)).setCalled(1)
    }

    @Test("When the course transition finishes, course tracking restores the requested maximum pitch")
    func courseMaximumPitch() {
        given(map).userTrackingMode.willReturn(.followWithCourse)
        let camera = MapViewCamera.trackUserLocationWithCourse(
            zoom: 8,
            pitch: 30,
            pitchRange: .freeWithinRange(minimum: 5, maximum: 45)
        )

        map.apply(camera: camera, animated: true)

        verify(map).maximumPitch(newValue: .value(45)).setCalled(1)
    }

    @Test("When the heading transition finishes, heading tracking preserves the native direction")
    func preserveHeading() {
        given(map).userTrackingMode.willReturn(.followWithHeading)

        map.apply(camera: .trackUserLocationWithHeading(zoom: 8), animated: true)

        verify(map).direction(newValue: .any).setCalled(0)
    }

    @Test("When the course transition finishes, course tracking preserves the native direction")
    func preserveCourse() {
        given(map).userTrackingMode.willReturn(.followWithCourse)

        map.apply(camera: .trackUserLocationWithCourse(zoom: 8), animated: true)

        verify(map).direction(newValue: .any).setCalled(0)
    }
}
