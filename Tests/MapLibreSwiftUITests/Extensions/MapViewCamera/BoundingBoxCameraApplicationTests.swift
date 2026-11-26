import MapLibre
import Mockable
import Testing
@testable import MapLibreSwiftUI

@MainActor
struct BoundingBoxCameraApplicationTests {
    let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
    let bounds = MLNCoordinateBounds.arrange()

    @Test("A bounding box forwards its bounds, padding, and animation to MapLibre", arguments: [false, true])
    func forwardBounds(animated: Bool) {
        let bounds = MLNCoordinateBounds.arrange(
            sw: .init(latitude: 40, longitude: 10),
            ne: .init(latitude: 50, longitude: 20)
        )
        let padding = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)

        map.apply(camera: .boundingBox(bounds, edgePadding: padding), animated: animated)

        verify(map).setVisibleCoordinateBounds(
            .value(bounds), edgePadding: .value(padding), animated: .value(animated), completionHandler: .any
        ).called(1)
    }

    @Test("A bounding box does not install a native completion handler")
    func omitCompletion() {
        var hasNoCompletion = false
        given(map).setVisibleCoordinateBounds(.any, edgePadding: .any, animated: .any, completionHandler: .any)
            .willProduce { _, _, _, completion in hasNoCompletion = completion == nil }

        map.apply(camera: .boundingBox(bounds), animated: false)

        #expect(hasNoCompletion)
    }

    @Test("A bounding box resets the minimum pitch to zero")
    func resetMinimumPitch() {
        map.apply(camera: .boundingBox(bounds), animated: false)

        verify(map).minimumPitch(newValue: .value(0)).setCalled(1)
    }

    @Test("A bounding box resets the maximum pitch to zero")
    func resetMaximumPitch() {
        map.apply(camera: .boundingBox(bounds), animated: false)

        verify(map).maximumPitch(newValue: .value(0)).setCalled(1)
    }

    @Test("A bounding box resets the direction to zero")
    func resetDirection() {
        map.apply(camera: .boundingBox(bounds), animated: false)

        verify(map).direction(newValue: .value(0)).setCalled(1)
    }
}
