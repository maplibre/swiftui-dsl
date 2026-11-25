import MapLibre
import Mockable
import Testing
@testable import MapLibreSwiftUI

@MainActor
struct CenteredCameraApplicationTests {
    @Test(arguments: [false, true])
    func centeredCameraBeforeLayoutForwardsTheNativeArguments(animated: Bool) {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        let coordinate = CLLocationCoordinate2D(latitude: 48, longitude: 16)
        given(map).frame.willReturn(.zero)

        applyCameraConfiguration(.center(coordinate, zoom: 12, direction: 82), to: map, animated: animated)

        verify(map).setCenter(
            .value(coordinate),
            zoomLevel: .value(12),
            direction: .value(82),
            animated: .value(animated)
        )
        .called(1)
    }

    @Test func centeredCameraStopsUserTracking() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(.zero)

        applyCameraConfiguration(.default(), to: map, animated: false)

        verify(map).userTrackingMode(newValue: .value(.none)).setCalled(1)
    }

    @Test func centeredCameraBeforeLayoutAppliesThenRestoresMinimumPitch() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(.zero)
        var pitches: [CGFloat] = []
        when(map).minimumPitch(newValue: .value(30)).performOnSet { pitches.append(30) }
        when(map).minimumPitch(newValue: .value(5)).performOnSet { pitches.append(5) }
        let camera = MapViewCamera.center(
            .init(),
            zoom: 10,
            pitch: 30,
            pitchRange: .freeWithinRange(minimum: 5, maximum: 45)
        )

        applyCameraConfiguration(camera, to: map, animated: false)

        #expect(pitches == [30, 5])
        verify(map).minimumPitch(newValue: .any).setCalled(2)
    }

    @Test func centeredCameraBeforeLayoutAppliesThenRestoresMaximumPitch() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(.zero)
        var pitches: [CGFloat] = []
        when(map).maximumPitch(newValue: .value(30)).performOnSet { pitches.append(30) }
        when(map).maximumPitch(newValue: .value(45)).performOnSet { pitches.append(45) }
        let camera = MapViewCamera.center(
            .init(),
            zoom: 10,
            pitch: 30,
            pitchRange: .freeWithinRange(minimum: 5, maximum: 45)
        )

        applyCameraConfiguration(camera, to: map, animated: false)

        #expect(pitches == [30, 45])
        verify(map).maximumPitch(newValue: .any).setCalled(2)
    }

    @Test func laidOutCenteredCameraSetsItsCoordinate() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        let nativeCamera = MLNMapCamera()
        let coordinate = CLLocationCoordinate2D(latitude: 48, longitude: 16)
        given(map).frame.willReturn(CGRect(x: 0, y: 0, width: 320, height: 240))
        given(map).camera.willReturn(nativeCamera)

        applyCameraConfiguration(.center(coordinate, zoom: 10), to: map, animated: false)

        #expect(nativeCamera.centerCoordinate == coordinate)
    }

    @Test func laidOutCenteredCameraSetsItsPitch() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        let nativeCamera = MLNMapCamera()
        given(map).frame.willReturn(CGRect(x: 0, y: 0, width: 320, height: 240))
        given(map).camera.willReturn(nativeCamera)

        applyCameraConfiguration(.center(.init(), zoom: 10, pitch: 30), to: map, animated: false)

        #expect(nativeCamera.pitch == 30)
    }

    @Test func laidOutCenteredCameraSetsItsHeading() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        let nativeCamera = MLNMapCamera()
        given(map).frame.willReturn(CGRect(x: 0, y: 0, width: 320, height: 240))
        given(map).camera.willReturn(nativeCamera)

        applyCameraConfiguration(.center(.init(), zoom: 10, direction: 80), to: map, animated: false)

        #expect(nativeCamera.heading == 80)
    }

    @Test func laidOutCenteredCameraConvertsZoomToAltitude() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        let nativeCamera = MLNMapCamera()
        let frame = CGRect(x: 0, y: 0, width: 320, height: 240)
        let coordinate = CLLocationCoordinate2D(latitude: 48, longitude: 16)
        given(map).frame.willReturn(frame)
        given(map).camera.willReturn(nativeCamera)

        applyCameraConfiguration(.center(coordinate, zoom: 14, pitch: 30), to: map, animated: false)

        #expect(nativeCamera.altitude == MLNAltitudeForZoomLevel(14, 30, coordinate.latitude, frame.size))
    }

    @Test func laidOutCenteredCameraForwardsAnimation() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        let nativeCamera = MLNMapCamera()
        given(map).frame.willReturn(CGRect(x: 0, y: 0, width: 320, height: 240))
        given(map).camera.willReturn(nativeCamera)

        applyCameraConfiguration(.default(), to: map, animated: true)

        verify(map).setCamera(.value(nativeCamera), animated: .value(true)).called(1)
    }

    @Test func laidOutCenteredCameraAppliesPitchBoundsBeforeTheCamera() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(CGRect(x: 0, y: 0, width: 320, height: 240))
        given(map).camera.willReturn(MLNMapCamera())
        var calls: [String] = []
        when(map).minimumPitch(newValue: .any).performOnSet { calls.append("minimum") }
        when(map).maximumPitch(newValue: .any).performOnSet { calls.append("maximum") }
        when(map).setCamera(.any, animated: .any).perform { calls.append("camera") }

        applyCameraConfiguration(.default(), to: map, animated: false)

        #expect(calls == ["minimum", "maximum", "camera"])
    }

    @Test func laidOutCenteredCameraSetsTheMinimumPitch() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(CGRect(x: 0, y: 0, width: 320, height: 240))
        given(map).camera.willReturn(MLNMapCamera())
        let camera = MapViewCamera.center(.init(), zoom: 10, pitchRange: .freeWithinRange(minimum: 5, maximum: 45))

        applyCameraConfiguration(camera, to: map, animated: false)

        verify(map).minimumPitch(newValue: .value(5)).setCalled(1)
    }

    @Test func laidOutCenteredCameraSetsTheMaximumPitch() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(CGRect(x: 0, y: 0, width: 320, height: 240))
        given(map).camera.willReturn(MLNMapCamera())
        let camera = MapViewCamera.center(.init(), zoom: 10, pitchRange: .freeWithinRange(minimum: 5, maximum: 45))

        applyCameraConfiguration(camera, to: map, animated: false)

        verify(map).maximumPitch(newValue: .value(45)).setCalled(1)
    }

    @Test func laidOutCenteredCameraStopsUserTracking() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(CGRect(x: 0, y: 0, width: 320, height: 240))
        given(map).camera.willReturn(MLNMapCamera())

        applyCameraConfiguration(.default(), to: map, animated: false)

        verify(map).userTrackingMode(newValue: .value(.none)).setCalled(1)
    }

    @Test func laidOutCenteredCameraDoesNotUseTheCenterShortcut() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).frame.willReturn(CGRect(x: 0, y: 0, width: 320, height: 240))
        given(map).camera.willReturn(MLNMapCamera())

        applyCameraConfiguration(.default(), to: map, animated: false)

        verify(map).setCenter(.any, zoomLevel: .any, direction: .any, animated: .any).called(0)
    }
}
