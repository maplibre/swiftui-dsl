import XCTest
import CoreLocation
@testable import MapLibreSwiftUI

final class CLLocationCoordinate2DTests: XCTestCase {

    func testHashable() {
        let coordinate = CLLocationCoordinate2D(latitude: 12.3, longitude: 23.4)
        
        var hasher = Hasher()
        coordinate.hash(into: &hasher)
        let hashedValue = hasher.finalize()
        
        XCTAssertEqual(hashedValue, coordinate.hashValue)
    }
}
