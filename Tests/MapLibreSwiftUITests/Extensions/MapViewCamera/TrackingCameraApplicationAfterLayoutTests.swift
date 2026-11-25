import MapLibre
import Mockable
import Testing
@testable import MapLibreSwiftUI

@MainActor
struct TrackingCameraApplicationAfterLayoutTests {
    let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)

    init() {
        given(map).frame.willReturn(CGRect(x: 0, y: 0, width: 320, height: 240))
    }

    @Test("After layout, location tracking forwards the follow mode and animation to MapLibre")
    func requestFollow() {
        map.apply(camera: .trackUserLocation(zoom: 8), animated: true)

        verify(map).setUserTrackingMode(.value(.follow), animated: .value(true), completionHandler: .any).called(1)
    }

    @Test("After layout, heading tracking forwards the tracking mode and animation to MapLibre")
    func requestHeading() {
        map.apply(camera: .trackUserLocationWithHeading(zoom: 8), animated: true)

        verify(map).setUserTrackingMode(.value(.followWithHeading), animated: .value(true), completionHandler: .any)
            .called(1)
    }

    @Test("After layout, course tracking forwards the tracking mode and animation to MapLibre")
    func requestCourse() {
        map.apply(camera: .trackUserLocationWithCourse(zoom: 8), animated: true)

        verify(map).setUserTrackingMode(.value(.followWithCourse), animated: .value(true), completionHandler: .any)
            .called(1)
    }
}
