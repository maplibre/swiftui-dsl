import CoreLocation
import MapLibre
import Testing
@testable import MapLibreSwiftUI

private final class DelegateSpy: NSObject, MLNLocationManagerDelegate {
    func locationManager(_: any MLNLocationManager, didUpdate _: [CLLocation]) {}
    func locationManager(_: any MLNLocationManager, didUpdate _: CLHeading) {}
    func locationManagerShouldDisplayHeadingCalibration(_: any MLNLocationManager) -> Bool {
        false
    }

    func locationManager(_: any MLNLocationManager, didFailWithError _: any Error) {}
    func locationManagerDidChangeAuthorization(_: any MLNLocationManager) {}
}

struct StaticLocationManagerTests {
    @Test("The manager does not keep its delegate alive")
    func delegateIsWeak() {
        let manager = StaticLocationManager(initialLocation: CLLocation())
        weak var weakDelegate: DelegateSpy?

        do {
            let delegate = DelegateSpy()
            weakDelegate = delegate
            manager.delegate = delegate
            #expect(manager.delegate != nil)
        }

        #expect(weakDelegate == nil)
        #expect(manager.delegate == nil)
    }
}
