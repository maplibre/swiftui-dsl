import MapLibre
import Mockable
import Testing
@testable import MapLibreSwiftUI

@MainActor
struct CenteredCameraApplicationAfterLayoutTests {
    let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
    let nativeCamera = MLNMapCamera()
    let frame = CGRect(x: 0, y: 0, width: 320, height: 240)

    init() {
        given(map).frame.willReturn(frame)
        given(map).camera.willReturn(nativeCamera)
    }

    @Test("After layout, a centered camera sets the native camera coordinate")
    func setCoordinate() {
        let coordinate = CLLocationCoordinate2D(latitude: 48, longitude: 16)

        map.apply(camera: .center(coordinate, zoom: 10), animated: false)

        #expect(nativeCamera.centerCoordinate == coordinate)
    }

    @Test("After layout, a centered camera sets the native camera pitch")
    func setPitch() {
        map.apply(camera: .center(.init(), zoom: 10, pitch: 30), animated: false)

        #expect(nativeCamera.pitch == 30)
    }

    @Test("After layout, a centered camera sets the native camera heading")
    func setHeading() {
        map.apply(camera: .center(.init(), zoom: 10, direction: 80), animated: false)

        #expect(nativeCamera.heading == 80)
    }

    @Test("After layout, a centered camera converts zoom to altitude for the map size and coordinate")
    func convertZoomToAltitude() {
        let coordinate = CLLocationCoordinate2D(latitude: 48, longitude: 16)

        map.apply(camera: .center(coordinate, zoom: 14, pitch: 30), animated: false)

        #expect(nativeCamera.altitude == MLNAltitudeForZoomLevel(14, 30, coordinate.latitude, frame.size))
    }

    @Test(
        "After layout, a centered camera forwards the animation flag to MapLibre",
        arguments: [true, false]
    )
    func forwardAnimation(animated: Bool) {
        map.apply(camera: .default(), animated: animated)

        verify(map).setCamera(.value(nativeCamera), animated: .value(animated)).called(1)
    }

    @Test("After layout, a centered camera applies pitch bounds before it sets the native camera")
    func applyPitchBoundsFirst() {
        var calls: [String] = []
        when(map).minimumPitch(newValue: .any).performOnSet { calls.append("minimum") }
        when(map).maximumPitch(newValue: .any).performOnSet { calls.append("maximum") }
        when(map).setCamera(.any, animated: .any).perform { calls.append("camera") }

        map.apply(camera: .default(), animated: false)

        #expect(calls == ["minimum", "maximum", "camera"])
    }

    @Test("After layout, a centered camera sets the minimum pitch")
    func setMinimumPitch() {
        let camera = MapViewCamera.center(.init(), zoom: 10, pitchRange: .freeWithinRange(minimum: 5, maximum: 45))

        map.apply(camera: camera, animated: false)

        verify(map).minimumPitch(newValue: .value(5)).setCalled(1)
    }

    @Test("After layout, a centered camera sets the maximum pitch")
    func setMaximumPitch() {
        let camera = MapViewCamera.center(.init(), zoom: 10, pitchRange: .freeWithinRange(minimum: 5, maximum: 45))

        map.apply(camera: camera, animated: false)

        verify(map).maximumPitch(newValue: .value(45)).setCalled(1)
    }

    @Test("After layout, a centered camera stops user tracking")
    func stopTrackingAfterLayout() {
        map.apply(camera: .default(), animated: false)

        verify(map).userTrackingMode(newValue: .value(.none)).setCalled(1)
    }

    @Test("After layout, a centered camera uses the native camera setter instead of the center setter")
    func useNativeCamera() {
        map.apply(camera: .default(), animated: false)

        verify(map).setCenter(.any, zoomLevel: .any, direction: .any, animated: .any).called(0)
    }
}
