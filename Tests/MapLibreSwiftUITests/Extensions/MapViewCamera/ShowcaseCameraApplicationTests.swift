import MapLibre
import Mockable
import Testing
@testable import MapLibreSwiftUI

@MainActor
struct ShowcaseCameraApplicationTests {
    let map = MockMLNMapViewRepresentable(policy: .relaxedVoid)
    let fittedCamera = MLNMapCamera()
    let shape = MLNShapeCollection(shapes: [])

    init() {
        given(map).cameraThatFitsShape(.any, direction: .any, edgePadding: .any).willReturn(fittedCamera)
    }

    @Test("A showcase forwards its shape and padding to native camera fitting")
    func fitShape() {
        let padding = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)

        map.apply(camera: .showcase(shapeCollection: shape, edgePadding: padding), animated: false)

        verify(map).cameraThatFitsShape(.value(shape), direction: .value(0), edgePadding: .value(padding)).called(1)
    }

    @Test("A showcase applies the fitted native camera with animation")
    func applyFittedCamera() {
        map.apply(camera: .showcase(shapeCollection: shape), animated: true)

        verify(map).setCamera(.value(fittedCamera), animated: .value(true)).called(1)
    }

    @Test("A showcase stops user tracking")
    func stopTracking() {
        map.apply(camera: .showcase(shapeCollection: shape), animated: false)

        verify(map).userTrackingMode(newValue: .value(.none)).setCalled(1)
    }

    @Test("A showcase resets the minimum pitch to zero")
    func resetMinimumPitch() {
        map.apply(camera: .showcase(shapeCollection: shape), animated: false)

        verify(map).minimumPitch(newValue: .value(0)).setCalled(1)
    }

    @Test("A showcase resets the maximum pitch to zero")
    func resetMaximumPitch() {
        map.apply(camera: .showcase(shapeCollection: shape), animated: false)

        verify(map).maximumPitch(newValue: .value(0)).setCalled(1)
    }

    @Test("A showcase resets the direction to zero (north up)")
    func resetDirection() {
        map.apply(camera: .showcase(shapeCollection: shape), animated: false)

        verify(map).direction(newValue: .value(0)).setCalled(1)
    }
}
