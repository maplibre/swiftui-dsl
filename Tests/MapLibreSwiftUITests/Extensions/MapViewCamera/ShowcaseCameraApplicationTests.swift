import MapLibre
import Mockable
import Testing
@testable import MapLibreSwiftUI

@MainActor
struct ShowcaseCameraApplicationTests {
    @Test func showcaseForwardsTheShapeAndPaddingToCameraFitting() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        let shape = MLNShapeCollection(shapes: [])
        let padding = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
        given(map).cameraThatFitsShape(.any, direction: .any, edgePadding: .any).willReturn(MLNMapCamera())

        applyCameraConfiguration(.showcase(shapeCollection: shape, edgePadding: padding), to: map, animated: false)

        verify(map).cameraThatFitsShape(.value(shape), direction: .value(0), edgePadding: .value(padding)).called(1)
    }

    @Test func showcaseAppliesTheFittedCameraWithAnimation() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        let fittedCamera = MLNMapCamera()
        given(map).cameraThatFitsShape(.any, direction: .any, edgePadding: .any).willReturn(fittedCamera)

        applyCameraConfiguration(.showcase(shapeCollection: MLNShapeCollection(shapes: [])), to: map, animated: true)

        verify(map).setCamera(.value(fittedCamera), animated: .value(true)).called(1)
    }

    @Test func showcaseStopsUserTracking() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).cameraThatFitsShape(.any, direction: .any, edgePadding: .any).willReturn(MLNMapCamera())

        applyCameraConfiguration(.showcase(shapeCollection: MLNShapeCollection(shapes: [])), to: map, animated: false)

        verify(map).userTrackingMode(newValue: .value(.none)).setCalled(1)
    }

    @Test func showcaseResetsTheMinimumPitch() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).cameraThatFitsShape(.any, direction: .any, edgePadding: .any).willReturn(MLNMapCamera())

        applyCameraConfiguration(.showcase(shapeCollection: MLNShapeCollection(shapes: [])), to: map, animated: false)

        verify(map).minimumPitch(newValue: .value(0)).setCalled(1)
    }

    @Test func showcaseResetsTheMaximumPitch() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).cameraThatFitsShape(.any, direction: .any, edgePadding: .any).willReturn(MLNMapCamera())

        applyCameraConfiguration(.showcase(shapeCollection: MLNShapeCollection(shapes: [])), to: map, animated: false)

        verify(map).maximumPitch(newValue: .value(0)).setCalled(1)
    }

    @Test func showcaseResetsTheDirection() {
        let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
        given(map).cameraThatFitsShape(.any, direction: .any, edgePadding: .any).willReturn(MLNMapCamera())

        applyCameraConfiguration(.showcase(shapeCollection: MLNShapeCollection(shapes: [])), to: map, animated: false)

        verify(map).direction(newValue: .value(0)).setCalled(1)
    }
}
