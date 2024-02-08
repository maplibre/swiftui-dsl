import SwiftUI
import XCTest
import SnapshotTesting
import MapLibreSwiftUI

// TODO: This is a WIP that needs some additional eyes
extension XCTestCase {
    
    func assertView<Content: View>(
        named name: String? = nil,
        record: Bool = false,
        frame: CGSize = CGSize(width: 430, height: 932),
        expectation: XCTestExpectation? = nil,
        @ViewBuilder content: () -> Content,
        file: StaticString = #file,
        testName: String = #function,
        line: UInt = #line
    ) {
        
        let view = content()
            .frame(width: frame.width, height: frame.height)
        
        assertSnapshot(matching: view,
                       as: .image(precision: 0.9, perceptualPrecision: 0.95),
                       named: name,
                       record: record,
                       file: file,
                       testName: testName,
                       line: line)
    }
}

// TODO: Figure this out, seems like the exp is being blocked or the map views onStyleLoaded is never run within the test context.
extension Snapshotting {
    static func wait(
        exp: XCTestExpectation,
        timeout: TimeInterval,
        on strategy: Self
    ) -> Self {
        Self(
            pathExtension: strategy.pathExtension,
            diffing: strategy.diffing,
            asyncSnapshot: { value in
                Async { callback in
                    _ = XCTWaiter.wait(for: [exp], timeout: timeout)
                    strategy.snapshot(value).run(callback)
                }
            }
        )
    }
}

