import MapLibre
import Mockable
import Testing
@testable import MapLibreSwiftUI

@MainActor
struct BoundingBoxCameraApplicationTests {
    @Test(arguments: [false, true])
    func boundingBoxForwardsTheNativeArguments(animated: Bool) {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        let bounds = MLNCoordinateBounds(sw: .init(latitude: 40, longitude: 10), ne: .init(latitude: 50, longitude: 20))
        let padding = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)

        applyCameraConfiguration(.boundingBox(bounds, edgePadding: padding), to: map, animated: animated)

        verify(map).setVisibleCoordinateBounds(
            .value(bounds), edgePadding: .value(padding), animated: .value(animated), completionHandler: .any
        ).called(1)
    }

    @Test func boundingBoxDoesNotInstallANativeCompletion() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        let bounds = MLNCoordinateBounds(sw: .init(), ne: .init())
        var hasNoCompletion = false
        given(map).setVisibleCoordinateBounds(.any, edgePadding: .any, animated: .any, completionHandler: .any)
            .willProduce { _, _, _, completion in hasNoCompletion = completion == nil }

        applyCameraConfiguration(.boundingBox(bounds), to: map, animated: false)

        #expect(hasNoCompletion)
    }

    @Test func boundingBoxResetsTheMinimumPitch() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        let bounds = MLNCoordinateBounds(sw: .init(), ne: .init())

        applyCameraConfiguration(.boundingBox(bounds), to: map, animated: false)

        verify(map).minimumPitch(newValue: .value(0)).setCalled(1)
    }

    @Test func boundingBoxResetsTheMaximumPitch() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        let bounds = MLNCoordinateBounds(sw: .init(), ne: .init())

        applyCameraConfiguration(.boundingBox(bounds), to: map, animated: false)

        verify(map).maximumPitch(newValue: .value(0)).setCalled(1)
    }

    @Test func boundingBoxResetsTheDirection() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        let bounds = MLNCoordinateBounds(sw: .init(), ne: .init())

        applyCameraConfiguration(.boundingBox(bounds), to: map, animated: false)

        verify(map).direction(newValue: .value(0)).setCalled(1)
    }
}
