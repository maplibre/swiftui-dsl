import MapLibre
import MapLibreSwiftDSL
import XCTest

final class StyleLayerTest: XCTestCase {
    func testBackgroundStyleLayer() throws {
        let styleLayer = BackgroundLayer(identifier: "background")
            .backgroundColor(.cyan)
            .backgroundOpacity(0.4)

        let mglStyleLayer = styleLayer.makeMLNStyleLayer() as! MLNBackgroundStyleLayer

        XCTAssertEqual(mglStyleLayer.backgroundColor, NSExpression(forConstantValue: UIColor.cyan))
        XCTAssertEqual(mglStyleLayer.backgroundOpacity.constantValue as! Double, 0.4, accuracy: 0.000001)
    }
}
