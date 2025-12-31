import CoreLocation
import MapLibre
import MapLibreSwiftDSL
import SwiftUI

#Preview("Tappable Circles") {
    let tappableID = "simple-circles"
    return MapView(styleURL: demoTilesURL, camera: .constant(.center(CLLocationCoordinate2D(), zoom: 0.0))) {
        // Simple symbol layer demonstration with an icon
        CircleStyleLayer(identifier: tappableID, source: pointSource)
            .radius(16)
            .color(.systemRed)
            .strokeWidth(2)
            .strokeColor(.white)

        SymbolStyleLayer(identifier: "simple-symbols", source: pointSource)
            .iconImage(UIImage(systemName: "mappin")!.withRenderingMode(.alwaysTemplate))
            .iconColor(.white)
    }
    .onTapMapGesture(on: [tappableID], onTapChanged: { _, features in
        print("Tapped on \(features.first?.description ?? "<nil>")")
    })
    .ignoresSafeArea(.all)
}

#Preview("Tappable Countries") {
    MapView(styleURL: demoTilesURL)
        .onTapMapGesture(on: ["countries-fill"], onTapChanged: { _, features in
            print("Tapped on \(features.first?.description ?? "<nil>")")
        })
        .ignoresSafeArea(.all)
}
