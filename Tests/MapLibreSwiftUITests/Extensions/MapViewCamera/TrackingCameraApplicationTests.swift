import MapLibre
import Mockable
import Testing
@testable import MapLibreSwiftUI

@MainActor
struct TrackingCameraApplicationTests {
    @Test func followBeforeLayoutSetsTheTrackingMode() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(.zero)

        applyCameraConfiguration(.trackUserLocation(zoom: 8), to: map, animated: true)

        verify(map).userTrackingMode(newValue: .value(.follow)).setCalled(1)
    }

    @Test func followBeforeLayoutSetsTheZoom() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(.zero)

        applyCameraConfiguration(.trackUserLocation(zoom: 8), to: map, animated: true)

        verify(map).zoomLevel(newValue: .value(8)).setCalled(1)
    }

    @Test func followAfterLayoutForwardsTheTrackingRequest() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(CGRect(x: 0, y: 0, width: 320, height: 240))

        applyCameraConfiguration(.trackUserLocation(zoom: 8), to: map, animated: true)

        verify(map).setUserTrackingMode(.value(.follow), animated: .value(true), completionHandler: .any).called(1)
    }

    @Test func headingBeforeLayoutSetsTheTrackingMode() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(.zero)

        applyCameraConfiguration(.trackUserLocationWithHeading(zoom: 8), to: map, animated: true)

        verify(map).userTrackingMode(newValue: .value(.followWithHeading)).setCalled(1)
    }

    @Test func headingBeforeLayoutSetsTheZoom() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(.zero)

        applyCameraConfiguration(.trackUserLocationWithHeading(zoom: 8), to: map, animated: true)

        verify(map).zoomLevel(newValue: .value(8)).setCalled(1)
    }

    @Test func headingAfterLayoutForwardsTheTrackingRequest() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(CGRect(x: 0, y: 0, width: 320, height: 240))

        applyCameraConfiguration(.trackUserLocationWithHeading(zoom: 8), to: map, animated: true)

        verify(map).setUserTrackingMode(.value(.followWithHeading), animated: .value(true), completionHandler: .any)
            .called(1)
    }

    @Test func courseBeforeLayoutSetsTheTrackingMode() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(.zero)

        applyCameraConfiguration(.trackUserLocationWithCourse(zoom: 8), to: map, animated: true)

        verify(map).userTrackingMode(newValue: .value(.followWithCourse)).setCalled(1)
    }

    @Test func courseBeforeLayoutSetsTheZoom() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(.zero)

        applyCameraConfiguration(.trackUserLocationWithCourse(zoom: 8), to: map, animated: true)

        verify(map).zoomLevel(newValue: .value(8)).setCalled(1)
    }

    @Test func courseAfterLayoutForwardsTheTrackingRequest() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(CGRect(x: 0, y: 0, width: 320, height: 240))

        applyCameraConfiguration(.trackUserLocationWithCourse(zoom: 8), to: map, animated: true)

        verify(map).setUserTrackingMode(.value(.followWithCourse), animated: .value(true), completionHandler: .any)
            .called(1)
    }

    @Test func followCompletionAppliesTheZoom() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(CGRect(x: 0, y: 0, width: 320, height: 240))
        given(map).userTrackingMode.willReturn(.follow)
        given(map).setUserTrackingMode(.any, animated: .any, completionHandler: .any)
            .willProduce { _, _, completion in completion?() }

        applyCameraConfiguration(.trackUserLocation(zoom: 8), to: map, animated: true)

        verify(map).zoomLevel(newValue: .value(8)).setCalled(1)
    }

    @Test func followCompletionIgnoresAChangedTrackingMode() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(CGRect(x: 0, y: 0, width: 320, height: 240))
        given(map).userTrackingMode.willReturn(.none)
        given(map).setUserTrackingMode(.any, animated: .any, completionHandler: .any)
            .willProduce { _, _, completion in completion?() }

        applyCameraConfiguration(.trackUserLocation(zoom: 8), to: map, animated: true)

        verify(map).zoomLevel(newValue: .any).setCalled(0)
    }

    @Test func followCompletionIgnoresAnOutdatedRequest() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(CGRect(x: 0, y: 0, width: 320, height: 240))
        given(map).userTrackingMode.willReturn(.follow)
        given(map).setUserTrackingMode(.any, animated: .any, completionHandler: .any)
            .willProduce { _, _, completion in completion?() }

        applyCameraConfiguration(.trackUserLocation(zoom: 8), to: map, animated: true, isCurrent: { false })

        verify(map).zoomLevel(newValue: .any).setCalled(0)
    }

    @Test func headingCompletionAppliesTheZoom() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(CGRect(x: 0, y: 0, width: 320, height: 240))
        given(map).userTrackingMode.willReturn(.followWithHeading)
        given(map).setUserTrackingMode(.any, animated: .any, completionHandler: .any)
            .willProduce { _, _, completion in completion?() }

        applyCameraConfiguration(.trackUserLocationWithHeading(zoom: 8), to: map, animated: true)

        verify(map).zoomLevel(newValue: .value(8)).setCalled(1)
    }

    @Test func headingCompletionIgnoresAChangedTrackingMode() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(CGRect(x: 0, y: 0, width: 320, height: 240))
        given(map).userTrackingMode.willReturn(.none)
        given(map).setUserTrackingMode(.any, animated: .any, completionHandler: .any)
            .willProduce { _, _, completion in completion?() }

        applyCameraConfiguration(.trackUserLocationWithHeading(zoom: 8), to: map, animated: true)

        verify(map).zoomLevel(newValue: .any).setCalled(0)
    }

    @Test func headingCompletionIgnoresAnOutdatedRequest() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(CGRect(x: 0, y: 0, width: 320, height: 240))
        given(map).userTrackingMode.willReturn(.followWithHeading)
        given(map).setUserTrackingMode(.any, animated: .any, completionHandler: .any)
            .willProduce { _, _, completion in completion?() }

        applyCameraConfiguration(.trackUserLocationWithHeading(zoom: 8), to: map, animated: true, isCurrent: { false })

        verify(map).zoomLevel(newValue: .any).setCalled(0)
    }

    @Test func courseCompletionAppliesTheZoom() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(CGRect(x: 0, y: 0, width: 320, height: 240))
        given(map).userTrackingMode.willReturn(.followWithCourse)
        given(map).setUserTrackingMode(.any, animated: .any, completionHandler: .any)
            .willProduce { _, _, completion in completion?() }

        applyCameraConfiguration(.trackUserLocationWithCourse(zoom: 8), to: map, animated: true)

        verify(map).zoomLevel(newValue: .value(8)).setCalled(1)
    }

    @Test func courseCompletionIgnoresAChangedTrackingMode() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(CGRect(x: 0, y: 0, width: 320, height: 240))
        given(map).userTrackingMode.willReturn(.none)
        given(map).setUserTrackingMode(.any, animated: .any, completionHandler: .any)
            .willProduce { _, _, completion in completion?() }

        applyCameraConfiguration(.trackUserLocationWithCourse(zoom: 8), to: map, animated: true)

        verify(map).zoomLevel(newValue: .any).setCalled(0)
    }

    @Test func courseCompletionIgnoresAnOutdatedRequest() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(CGRect(x: 0, y: 0, width: 320, height: 240))
        given(map).userTrackingMode.willReturn(.followWithCourse)
        given(map).setUserTrackingMode(.any, animated: .any, completionHandler: .any)
            .willProduce { _, _, completion in completion?() }

        applyCameraConfiguration(.trackUserLocationWithCourse(zoom: 8), to: map, animated: true, isCurrent: { false })

        verify(map).zoomLevel(newValue: .any).setCalled(0)
    }

    @Test func followBeforeLayoutSetsTheDirection() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(.zero)

        applyCameraConfiguration(.trackUserLocation(zoom: 8, direction: 82), to: map, animated: true)

        verify(map).direction(newValue: .value(82)).setCalled(1)
    }

    @Test func followCompletionSetsTheDirection() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(CGRect(x: 0, y: 0, width: 320, height: 240))
        given(map).userTrackingMode.willReturn(.follow)
        given(map).setUserTrackingMode(.any, animated: .any, completionHandler: .any)
            .willProduce { _, _, completion in completion?() }

        applyCameraConfiguration(.trackUserLocation(zoom: 8, direction: 82), to: map, animated: true)

        verify(map).direction(newValue: .value(82)).setCalled(1)
    }

    @Test func followCompletionRestoresTheMinimumPitch() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(CGRect(x: 0, y: 0, width: 320, height: 240))
        given(map).userTrackingMode.willReturn(.follow)
        given(map).setUserTrackingMode(.any, animated: .any, completionHandler: .any)
            .willProduce { _, _, completion in completion?() }
        let camera = MapViewCamera.trackUserLocation(
            zoom: 8,
            pitch: 30,
            pitchRange: .freeWithinRange(minimum: 5, maximum: 45)
        )

        applyCameraConfiguration(camera, to: map, animated: true)

        verify(map).minimumPitch(newValue: .value(5)).setCalled(1)
    }

    @Test func followCompletionRestoresTheMaximumPitch() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(CGRect(x: 0, y: 0, width: 320, height: 240))
        given(map).userTrackingMode.willReturn(.follow)
        given(map).setUserTrackingMode(.any, animated: .any, completionHandler: .any)
            .willProduce { _, _, completion in completion?() }
        let camera = MapViewCamera.trackUserLocation(
            zoom: 8,
            pitch: 30,
            pitchRange: .freeWithinRange(minimum: 5, maximum: 45)
        )

        applyCameraConfiguration(camera, to: map, animated: true)

        verify(map).maximumPitch(newValue: .value(45)).setCalled(1)
    }

    @Test func headingCompletionRestoresTheMinimumPitch() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(CGRect(x: 0, y: 0, width: 320, height: 240))
        given(map).userTrackingMode.willReturn(.followWithHeading)
        given(map).setUserTrackingMode(.any, animated: .any, completionHandler: .any)
            .willProduce { _, _, completion in completion?() }
        let camera = MapViewCamera.trackUserLocationWithHeading(
            zoom: 8,
            pitch: 30,
            pitchRange: .freeWithinRange(minimum: 5, maximum: 45)
        )

        applyCameraConfiguration(camera, to: map, animated: true)

        verify(map).minimumPitch(newValue: .value(5)).setCalled(1)
    }

    @Test func headingCompletionRestoresTheMaximumPitch() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(CGRect(x: 0, y: 0, width: 320, height: 240))
        given(map).userTrackingMode.willReturn(.followWithHeading)
        given(map).setUserTrackingMode(.any, animated: .any, completionHandler: .any)
            .willProduce { _, _, completion in completion?() }
        let camera = MapViewCamera.trackUserLocationWithHeading(
            zoom: 8,
            pitch: 30,
            pitchRange: .freeWithinRange(minimum: 5, maximum: 45)
        )

        applyCameraConfiguration(camera, to: map, animated: true)

        verify(map).maximumPitch(newValue: .value(45)).setCalled(1)
    }

    @Test func courseCompletionRestoresTheMinimumPitch() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(CGRect(x: 0, y: 0, width: 320, height: 240))
        given(map).userTrackingMode.willReturn(.followWithCourse)
        given(map).setUserTrackingMode(.any, animated: .any, completionHandler: .any)
            .willProduce { _, _, completion in completion?() }
        let camera = MapViewCamera.trackUserLocationWithCourse(
            zoom: 8,
            pitch: 30,
            pitchRange: .freeWithinRange(minimum: 5, maximum: 45)
        )

        applyCameraConfiguration(camera, to: map, animated: true)

        verify(map).minimumPitch(newValue: .value(5)).setCalled(1)
    }

    @Test func courseCompletionRestoresTheMaximumPitch() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(CGRect(x: 0, y: 0, width: 320, height: 240))
        given(map).userTrackingMode.willReturn(.followWithCourse)
        given(map).setUserTrackingMode(.any, animated: .any, completionHandler: .any)
            .willProduce { _, _, completion in completion?() }
        let camera = MapViewCamera.trackUserLocationWithCourse(
            zoom: 8,
            pitch: 30,
            pitchRange: .freeWithinRange(minimum: 5, maximum: 45)
        )

        applyCameraConfiguration(camera, to: map, animated: true)

        verify(map).maximumPitch(newValue: .value(45)).setCalled(1)
    }

    @Test func headingCompletionPreservesTheNativeDirection() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(CGRect(x: 0, y: 0, width: 320, height: 240))
        given(map).userTrackingMode.willReturn(.followWithHeading)
        given(map).setUserTrackingMode(.any, animated: .any, completionHandler: .any)
            .willProduce { _, _, completion in completion?() }

        applyCameraConfiguration(.trackUserLocationWithHeading(zoom: 8), to: map, animated: true)

        verify(map).direction(newValue: .any).setCalled(0)
    }

    @Test func courseCompletionPreservesTheNativeDirection() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(CGRect(x: 0, y: 0, width: 320, height: 240))
        given(map).userTrackingMode.willReturn(.followWithCourse)
        given(map).setUserTrackingMode(.any, animated: .any, completionHandler: .any)
            .willProduce { _, _, completion in completion?() }

        applyCameraConfiguration(.trackUserLocationWithCourse(zoom: 8), to: map, animated: true)

        verify(map).direction(newValue: .any).setCalled(0)
    }
}
