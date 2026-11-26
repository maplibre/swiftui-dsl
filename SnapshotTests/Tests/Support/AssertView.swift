import Foundation
import MapLibreSwiftUI
import SnapshotTesting
import SwiftUI
import Testing

@MainActor
func assertView(
    named name: String? = nil,
    record: Bool = false,
    colorScheme: ColorScheme = .light,
    timeout: TimeInterval = 30,
    waitUntil isReady: (@MainActor () -> Bool)? = nil,
    afterSnapshot action: (@MainActor () async throws -> Void)? = nil,
    waitUntilAfterAction isReadyAfterAction: (@MainActor () -> Bool)? = nil,
    @ViewBuilder content: @MainActor () -> some View,
    file: StaticString = #filePath,
    fileID: StaticString = #fileID,
    testName: String = #function,
    line: UInt = #line
) async throws {
    let hostWindow = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap(\.windows)
        .first(where: \.isKeyWindow)

    // Get the key window from the hosting App
    let window = try #require(hostWindow)

    var rendered = false
    var idle = false
    let controller = UIHostingController(
        rootView: content()
            .environment(\.colorScheme, colorScheme)
            .transaction { $0.disablesAnimations = true }
            .onMapStyleLoaded { $0.performsPlacementTransitions = false }
            .onMapDidFinishRendering { _, fullyRendered in rendered = fullyRendered }
            .onMapIdle { _ in idle = true }
    )
    controller.overrideUserInterfaceStyle = colorScheme == .dark ? .dark : .light
    window.rootViewController = controller
    defer { window.rootViewController = nil }
    window.layoutIfNeeded()

    func waitUntilReady(_ isReady: (@MainActor () -> Bool)?) async throws {
        let deadline = ContinuousClock.now + .seconds(timeout)
        while !rendered || !(isReady?() ?? idle) {
            try #require(
                ContinuousClock.now < deadline,
                "The map or preview timed out (rendered: \(rendered), ready: \(isReady?() ?? idle))."
            )
            try await Task.sleep(for: .milliseconds(10))
        }
        // Allow Metal to present the completed frame.
        try await Task.sleep(for: .milliseconds(50))
    }

    func renderImage() -> UIImage {
        let traits = controller.traitCollection.modifyingTraits { $0.displayGamut = .SRGB }
        return UIGraphicsImageRenderer(bounds: controller.view.bounds, format: .init(for: traits)).image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }

    func differenceImage(reference: UIImage, actual: UIImage) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = max(reference.scale, actual.scale)
        format.opaque = true
        let size = CGSize(
            width: max(reference.size.width, actual.size.width),
            height: max(reference.size.height, actual.size.height)
        )
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            actual.draw(at: .zero)
            reference.draw(at: .zero, blendMode: .difference, alpha: 1)
        }
    }

    func attachArtifacts(
        to snapshotting: inout Snapshotting<UIImage, UIImage>,
        actual image: UIImage,
        named name: String?
    ) throws {
        let data = try #require(image.pngData())
        let attachmentName = "\(testName)-\(name ?? "1")"
        Attachment.record(data, named: "\(attachmentName)-actual.png")
        let diffing = snapshotting.diffing
        snapshotting.diffing.diff = { reference, actual in
            guard let failure = diffing.diff(reference, actual) else { return nil }
            Attachment.record(diffing.toData(reference), named: "\(attachmentName)-reference.png")
            let difference = differenceImage(reference: reference, actual: actual)
            Attachment.record(diffing.toData(difference), named: "\(attachmentName)-diff.png")
            return failure
        }
    }

    func capture(named name: String?, when isReady: (@MainActor () -> Bool)?) async throws {
        try await waitUntilReady(isReady)
        let image = renderImage()
        var snapshotting = Snapshotting<UIImage, UIImage>.image(precision: 0.9999, perceptualPrecision: 0.98)
        try attachArtifacts(to: &snapshotting, actual: image, named: name)
        assertSnapshot(
            of: image,
            as: snapshotting,
            named: name ?? "1",
            record: record,
            fileID: fileID,
            file: file,
            testName: testName,
            line: line
        )
    }

    let prefix = name.map { "\($0)-" } ?? ""
    try await capture(named: action == nil ? name : "\(prefix)before", when: isReady)
    if let action {
        idle = false
        try await action()
        try await capture(named: "\(prefix)after", when: isReadyAfterAction)
    }
}
