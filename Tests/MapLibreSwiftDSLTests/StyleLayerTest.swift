import XCTest
import MapLibre
import MapLibreSwiftDSL

final class StyleLayerTest: XCTestCase {
    func testBackgroundStyleLayer() throws {
        let styleLayer = BackgroundLayer(identifier: "background")
            .backgroundColor(constant: .cyan)
            .backgroundOpacity(constant: 0.4)

        let mglStyleLayer = styleLayer.makeMGLStyleLayer() as! MLNBackgroundStyleLayer

        XCTAssertEqual(mglStyleLayer.backgroundColor, NSExpression(forConstantValue: UIColor.cyan))
        XCTAssertEqual(mglStyleLayer.backgroundOpacity.constantValue as! Double, 0.4, accuracy: 0.000001)
    }
}
