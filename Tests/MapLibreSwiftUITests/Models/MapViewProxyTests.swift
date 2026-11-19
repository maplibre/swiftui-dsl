import CoreLocation
import MapLibre
import Mockable
import Testing
@testable import MapLibreSwiftUI

@MainActor
struct MapViewProxyTests {
    @Test(arguments: [0.0, 37.5, 60.0])
    func cameraSnapshotPreservesPitch(pitch: Double) {
        let map = MockMLNMapViewRepresentable()
        let center = CLLocationCoordinate2D(latitude: 45, longitude: -127)
        let nativeCamera = MLNMapCamera()
        nativeCamera.pitch = CGFloat(pitch)
        given(map).centerCoordinate.willReturn(center)
        given(map).zoomLevel.willReturn(14)
        given(map).direction.willReturn(82)
        given(map).camera.willReturn(nativeCamera)
        let proxy = MapViewProxy(mapView: map, lastReasonForChange: .programmatic)

        #expect(proxy.pitch == pitch)
        #expect(proxy.asMapViewCamera() == .center(center, zoom: 14, pitch: pitch, direction: 82))
        verify(map).setCamera(.any, animated: .any).called(0)
        verify(map).setCenter(.any, zoomLevel: .any, direction: .any, animated: .any).called(0)
    }
}
