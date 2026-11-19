import MapLibre
import MapLibreSwiftUI
import SwiftUI
import XCTest

final class MapStyleLoadedEnvironmentTests: XCTestCase {
    @MainActor func testWrapperForwardsStyleCallbackAndKeepsItsInternalHandler() async throws {
        let url = try makeStyle()
        defer { try? FileManager.default.removeItem(at: url) }
        let loaded = expectation(description: "Parent receives the wrapper's loaded style")
        var internalStyle: MLNStyle?
        let view = ForwardingStyleMap(styleURL: url) { internalStyle = $0 }
            .onMapStyleLoaded { style in
                XCTAssertTrue(internalStyle === style)
                loaded.fulfill()
            }
        let window = show(view)
        defer { window.isHidden = true; window.rootViewController = nil }
        await fulfillment(of: [loaded], timeout: 5)
    }

    @MainActor func testReloadUsesUpdatedParentHandler() async throws {
        let firstURL = try makeStyle()
        let secondURL = try makeStyle()
        defer {
            try? FileManager.default.removeItem(at: firstURL)
            try? FileManager.default.removeItem(at: secondURL)
        }
        let firstLoaded = expectation(description: "Initial handler")
        let secondLoaded = expectation(description: "Updated handler")
        var internalCalls = 0
        let host = UIHostingController(rootView: forwardingMap(styleURL: firstURL, internalHandler: {
            internalCalls += 1
        }, parentHandler: {
            firstLoaded.fulfill()
        }))
        let window = showController(host)
        defer { window.isHidden = true; window.rootViewController = nil }
        await fulfillment(of: [firstLoaded], timeout: 5)

        host.rootView = forwardingMap(styleURL: secondURL, internalHandler: {
            internalCalls += 1
        }, parentHandler: {
            secondLoaded.fulfill()
        })
        host.view.layoutIfNeeded()
        await fulfillment(of: [secondLoaded], timeout: 5)
        XCTAssertEqual(internalCalls, 2)
    }

    @MainActor func testSiblingMapsKeepTheirOwnCallbacks() async throws {
        let url = try makeStyle()
        defer { try? FileManager.default.removeItem(at: url) }
        let firstLoaded = expectation(description: "First map")
        let secondLoaded = expectation(description: "Second map")
        var firstStyle: MLNStyle?
        var secondStyle: MLNStyle?
        let view = HStack {
            ForwardingStyleMap(styleURL: url) { firstStyle = $0 }
                .onMapStyleLoaded { style in
                    XCTAssertTrue(firstStyle === style)
                    firstLoaded.fulfill()
                }
            ForwardingStyleMap(styleURL: url) { secondStyle = $0 }
                .onMapStyleLoaded { style in
                    XCTAssertTrue(secondStyle === style)
                    secondLoaded.fulfill()
                }
        }
        let window = show(view)
        defer { window.isHidden = true; window.rootViewController = nil }
        await fulfillment(of: [firstLoaded, secondLoaded], timeout: 5)
        XCTAssertFalse(firstStyle === secondStyle)
    }

    private func makeStyle() throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".json")
        try Data(#"{"version":8,"sources":{},"layers":[]}"#.utf8).write(to: url)
        return url
    }

    @MainActor private func forwardingMap(styleURL: URL, internalHandler: @escaping () -> Void,
                                          parentHandler: @escaping () -> Void) -> some View
    {
        ForwardingStyleMap(styleURL: styleURL) { _ in internalHandler() }
            .onMapStyleLoaded { _ in parentHandler() }
    }

    @MainActor private func show(_ view: some View) -> UIWindow {
        showController(UIHostingController(rootView: view))
    }

    @MainActor private func showController(_ host: UIViewController) -> UIWindow {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = host
        window.makeKeyAndVisible()
        host.view.layoutIfNeeded()
        return window
    }
}

private struct ForwardingStyleMap: View {
    @Environment(\.onMapStyleLoaded) private var parentHandler
    let styleURL: URL
    let internalHandler: (MLNStyle) -> Void

    var body: some View {
        MapView(styleURL: styleURL)
            .onMapStyleLoaded { style in
                internalHandler(style)
                parentHandler?(style)
            }
    }
}
