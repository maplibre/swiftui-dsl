import CoreLocation
import MapLibre
import MapLibreSwiftDSL
import MapLibreSwiftUI
import SwiftUI

private let switzerland = CLLocationCoordinate2D(latitude: 47.03041, longitude: 8.29470)

/// Changes the camera while the content inset changes, as an app showing and hiding a panel over the map does.
struct CameraVsInsetPreview: View {
    let styleURL: URL

    @State private var camera = MapViewCamera.center(zurich, zoom: 8, pitch: 60)
    @State private var contentInset = largeInset
    @State private var proxy: MapViewProxy?
    @State private var isMeasuring = false
    @State private var outcome: ViewportOutcome?

    private static let zurich = CLLocationCoordinate2D(latitude: 47.3769, longitude: 8.5417)
    private static let largeInset = UIEdgeInsets(top: 300, left: 0, bottom: 0, right: 0)
    private static let smallInset = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)

    /// Latitude and longitude lines, so pitch is visible where the tiles are a single flat color.
    private static let graticule = LineStyleLayer(
        identifier: "graticule-line",
        source: ShapeSource(identifier: "graticule") {
            stride(from: -180.0, through: 180.0, by: 1.0).map { longitude in
                MLNPolylineFeature(coordinates: [
                    CLLocationCoordinate2D(latitude: -85, longitude: longitude),
                    CLLocationCoordinate2D(latitude: 85, longitude: longitude),
                ])
            }
            stride(from: -85.0, through: 85.0, by: 1.0).map { latitude in
                MLNPolylineFeature(coordinates: [
                    CLLocationCoordinate2D(latitude: latitude, longitude: -180),
                    CLLocationCoordinate2D(latitude: latitude, longitude: 180),
                ])
            }
        }
    )
    .lineColor(.darkGray)
    .lineWidth(1)

    var body: some View {
        MapView(styleURL: styleURL, camera: $camera) {
            Self.graticule
        }
        .mapContentInset(contentInset)
        .onMapViewProxyUpdate { proxy = $0 }
        .overlay(alignment: .top) {
            Text("Content inset ↓")
                .foregroundColor(.white)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .frame(height: contentInset.top)
                .background(Color.black.opacity(0.3))
                .animation(.easeInOut, value: contentInset.top)
                .allowsHitTesting(false)
        }
        .overlay(alignment: .bottom) {
            VStack(spacing: 16) {
                ViewportExpectationPanel(
                    description: """
                    The camera is pitched 60° over Zurich, with a top content inset (shaded). \
                    "Proceed" will flatten the pitch and zoom out to Switzerland, \
                    while simultaneously reducing the content inset.
                    """,
                    expected: "0° pitch, zoom 6.0",
                    outcome: outcome,
                    isMeasuring: isMeasuring
                )

                Button("Proceed") {
                    Task { await proceed() }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(isMeasuring || outcome != nil)
            }
            .padding(.horizontal)
            .padding(.bottom, 42)
        }
    }

    private func proceed() async {
        isMeasuring = true
        camera = .center(switzerland, zoom: 6)
        try? await Task.sleep(nanoseconds: 150_000_000)
        contentInset = Self.smallInset
        try? await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)
        if let proxy {
            outcome = ViewportOutcome(
                actual: String(format: "%.0f° pitch, zoom %.1f", proxy.pitch, proxy.zoomLevel),
                isExpected: abs(proxy.pitch) < 1 && abs(proxy.zoomLevel - 6) < 0.1
            )
        }
        isMeasuring = false
    }
}

#Preview("Camera vs. Inset") {
    CameraVsInsetPreview(styleURL: demoTilesURL)
        .ignoresSafeArea(.all)
}

/// Grows the map after fitting a bounding box camera to it.
struct ResizeVsFitPreview: View {
    let styleURL: URL

    @State private var camera = MapViewCamera.center(switzerland, zoom: 6)
    @State private var isMapShrunk = true
    @State private var proxy: MapViewProxy?
    @State private var isMeasuring = false
    @State private var outcome: ViewportOutcome?

    private static let italy = MLNCoordinateBounds(
        sw: CLLocationCoordinate2D(latitude: 36.6, longitude: 6.6),
        ne: CLLocationCoordinate2D(latitude: 47.1, longitude: 18.5)
    )
    private static let margin: CGFloat = 20

    var body: some View {
        GeometryReader { geometry in
            let contentInset = UIEdgeInsets(
                top: geometry.safeAreaInsets.top + Self.margin,
                left: Self.margin,
                bottom: Self.margin,
                right: Self.margin
            )

            VStack(spacing: 8) {
                MapView(styleURL: styleURL, camera: $camera)
                    .mapContentInset(contentInset)
                    .onMapViewProxyUpdate { proxy = $0 }
                    .overlay {
                        Rectangle()
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                            .foregroundColor(.black)
                            .overlay(alignment: .topLeading) {
                                Text("Content area")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 4)
                                    .background(Color.black.opacity(0.6))
                                    .padding(4)
                            }
                            .padding(EdgeInsets(
                                top: contentInset.top,
                                leading: contentInset.left,
                                bottom: contentInset.bottom,
                                trailing: contentInset.right
                            ))
                            .allowsHitTesting(false)
                    }
                    .frame(height: isMapShrunk ? 250 : nil)

                if isMapShrunk {
                    Image(systemName: "arrow.down")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .overlay(alignment: .bottom) {
                VStack(spacing: 16) {
                    ViewportExpectationPanel(
                        description: """
                        The map is shrunk, with Italy fit to its content area (dashed). \
                        "Grow" will grow the map to full height.
                        """,
                        expected: "Italy fills 100%",
                        outcome: outcome,
                        isMeasuring: isMeasuring
                    )

                    Button {
                        Task { await grow() }
                    } label: {
                        Label("Grow", systemImage: "arrow.down")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!isMapShrunk)
                }
                .padding(.horizontal)
                .padding(.bottom, 42)
            }
            .ignoresSafeArea()
        }
        .task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            camera = .boundingBox(Self.italy, edgePadding: .zero)
        }
    }

    private func grow() async {
        isMeasuring = true
        isMapShrunk = false
        try? await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)
        if let proxy {
            outcome = measureItalyFill(proxy)
        }
        isMeasuring = false
    }

    /// How much of the content area Italy spans in its limiting dimension.
    private func measureItalyFill(_ proxy: MapViewProxy) -> ViewportOutcome {
        let southWest = proxy.convert(Self.italy.sw, toPointTo: nil)
        let northEast = proxy.convert(Self.italy.ne, toPointTo: nil)
        let inset = proxy.contentInset
        let fill = max(
            abs(northEast.x - southWest.x) / (proxy.mapViewSize.width - inset.left - inset.right),
            abs(northEast.y - southWest.y) / (proxy.mapViewSize.height - inset.top - inset.bottom)
        )
        return ViewportOutcome(
            actual: String(format: "Italy fills %.0f%%", fill * 100),
            isExpected: abs(fill - 1) < 0.05
        )
    }
}

#Preview("Resize vs. Fit") {
    ResizeVsFitPreview(styleURL: demoTilesURL)
}

private struct ViewportOutcome {
    let actual: String
    let isExpected: Bool
}

/// Describes what the button will do, then compares the expected result with the actual one.
private struct ViewportExpectationPanel: View {
    let description: String
    let expected: String
    let outcome: ViewportOutcome?
    let isMeasuring: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(description)
            VStack(alignment: .leading, spacing: 2) {
                row("Expected", expected)
                row("Actual", outcome?.actual ?? (isMeasuring ? "" : "—")) {
                    if isMeasuring {
                        ProgressView()
                            .tint(.white)
                    } else if let outcome {
                        Image(systemName: outcome.isExpected ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, outcome.isExpected ? .green : .red)
                    }
                }
            }
            .monospacedDigit()
            .padding(.top, 4)
        }
        .font(.callout)
        .foregroundColor(.white)
        .padding(10)
        .background(
            Rectangle()
                .foregroundColor(.black.opacity(0.75))
                .cornerRadius(8)
        )
    }

    private func row(
        _ label: String,
        _ value: String,
        @ViewBuilder indicator: () -> some View = { EmptyView() }
    ) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .bold()
                .frame(width: 72, alignment: .leading)
            Text(value)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            indicator()
        }
    }
}
