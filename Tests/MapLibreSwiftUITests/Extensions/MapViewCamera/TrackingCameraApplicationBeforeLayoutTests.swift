import MapLibre
import Mockable
import Testing
@testable import MapLibreSwiftUI

@MainActor
struct TrackingCameraApplicationBeforeLayoutTests {
    let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)

    init() {
        given(map).frame.willReturn(.zero)
    }

    @Test("Before layout, location tracking sets the native tracking mode to follow")
    func followBeforeLayout() {
        map.apply(camera: .trackUserLocation(zoom: 8), animated: true)

        verify(map).userTrackingMode(newValue: .value(.follow)).setCalled(1)
    }

    @Test("Before layout, location tracking sets the requested zoom")
    func followZoomBeforeLayout() {
        map.apply(camera: .trackUserLocation(zoom: 8), animated: true)

        verify(map).zoomLevel(newValue: .value(8)).setCalled(1)
    }

    @Test("Before layout, heading tracking sets the native tracking mode to follow with heading")
    func headingBeforeLayout() {
        map.apply(camera: .trackUserLocationWithHeading(zoom: 8), animated: true)

        verify(map).userTrackingMode(newValue: .value(.followWithHeading)).setCalled(1)
    }

    @Test("Before layout, heading tracking sets the requested zoom")
    func headingZoomBeforeLayout() {
        map.apply(camera: .trackUserLocationWithHeading(zoom: 8), animated: true)

        verify(map).zoomLevel(newValue: .value(8)).setCalled(1)
    }

    @Test("Before layout, course tracking sets the native tracking mode to follow with course")
    func courseBeforeLayout() {
        map.apply(camera: .trackUserLocationWithCourse(zoom: 8), animated: true)

        verify(map).userTrackingMode(newValue: .value(.followWithCourse)).setCalled(1)
    }

    @Test("Before layout, course tracking sets the requested zoom")
    func courseZoomBeforeLayout() {
        map.apply(camera: .trackUserLocationWithCourse(zoom: 8), animated: true)

        verify(map).zoomLevel(newValue: .value(8)).setCalled(1)
    }

    @Test("Before layout, location tracking sets the requested direction")
    func followDirectionBeforeLayout() {
        map.apply(camera: .trackUserLocation(zoom: 8, direction: 82), animated: true)

        verify(map).direction(newValue: .value(82)).setCalled(1)
    }
}
