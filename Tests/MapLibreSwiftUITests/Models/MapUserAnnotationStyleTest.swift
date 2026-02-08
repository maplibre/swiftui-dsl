import Testing
@testable import MapLibreSwiftUI

struct MapUserAnnotationStyleTest {
    @Test("The MapUserAnnotationStyle values are properly assigned")
    func values() {
        let custom = MapUserAnnotationStyle(
            approximateHaloBorderColor: .orange,
            approximateHaloBorderWidth: 50,
            approximateHaloFillColor: .blue,
            approximateHaloOpacity: 0.5,
            haloFillColor: .green,
            puckArrowFillColor: .yellow,
            puckFillColor: .red,
            puckShadowColor: .pink,
            puckShadowOpacity: 0.1
        )
        let mlnValue = custom.value

        #expect(mlnValue.approximateHaloBorderColor == .systemOrange)
        #expect(mlnValue.approximateHaloBorderWidth == 50)
        #expect(mlnValue.approximateHaloFillColor == .systemBlue)
        #expect(mlnValue.approximateHaloOpacity == 0.5)
        #expect(mlnValue.haloFillColor == .systemGreen)
        #expect(mlnValue.puckArrowFillColor == .systemYellow)
        #expect(mlnValue.puckFillColor == .systemRed)
        #expect(mlnValue.puckShadowColor == .systemPink)
        #expect(mlnValue.puckShadowOpacity == 0.1)
    }
}
