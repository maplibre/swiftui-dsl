import MapLibre
import Mockable
import Testing
@testable import MapLibreSwiftUI

@MainActor
struct CenteredCameraApplicationBeforeLayoutTests {
    let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)

    init() {
        given(map).frame.willReturn(.zero)
    }

    @Test(
        "Before layout, a centered camera forwards its coordinate, zoom, direction, and animation to MapLibre",
        arguments: [false, true]
    )
    func forwardCenterBeforeLayout(animated: Bool) {
        let coordinate = CLLocationCoordinate2D(latitude: 48, longitude: 16)

        map.apply(camera: .center(coordinate, zoom: 12, direction: 82), animated: animated)

        verify(map).setCenter(
            .value(coordinate),
            zoomLevel: .value(12),
            direction: .value(82),
            animated: .value(animated)
        )
        .called(1)
    }

    @Test("Before layout, a centered camera stops user tracking")
    func stopTrackingBeforeLayout() {
        map.apply(camera: .default(), animated: false)

        verify(map).userTrackingMode(newValue: .value(.none)).setCalled(1)
    }

    @Test("Before layout, a centered camera applies its pitch and then restores the minimum pitch")
    func restoreMinimumPitchBeforeLayout() {
        var pitches: [CGFloat] = []
        when(map).minimumPitch(newValue: .value(30)).performOnSet { pitches.append(30) }
        when(map).minimumPitch(newValue: .value(5)).performOnSet { pitches.append(5) }
        let camera = MapViewCamera.center(
            .init(),
            zoom: 10,
            pitch: 30,
            pitchRange: .freeWithinRange(minimum: 5, maximum: 45)
        )

        map.apply(camera: camera, animated: false)

        #expect(pitches == [30, 5])
        verify(map).minimumPitch(newValue: .any).setCalled(2)
    }

    @Test("Before layout, a centered camera applies its pitch and then restores the maximum pitch")
    func restoreMaximumPitchBeforeLayout() {
        var pitches: [CGFloat] = []
        when(map).maximumPitch(newValue: .value(30)).performOnSet { pitches.append(30) }
        when(map).maximumPitch(newValue: .value(45)).performOnSet { pitches.append(45) }
        let camera = MapViewCamera.center(
            .init(),
            zoom: 10,
            pitch: 30,
            pitchRange: .freeWithinRange(minimum: 5, maximum: 45)
        )

        map.apply(camera: camera, animated: false)

        #expect(pitches == [30, 45])
        verify(map).maximumPitch(newValue: .any).setCalled(2)
    }
}
