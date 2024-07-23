import MapLibreSwiftUI
import SnapshotTesting
import SwiftUI
import XCTest

extension XCTestCase {
    func assertView(
        named name: String? = nil,
        record: Bool = false,
        frame: CGSize = CGSize(width: 430, height: 932),
        expectation _: XCTestExpectation? = nil,
        @ViewBuilder content: () -> some View,
        file: StaticString = #file,
        testName: String = #function,
        line: UInt = #line
    ) {
        let view = content()
            .frame(width: frame.width, height: frame.height)

        assertSnapshot(of: view,
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
