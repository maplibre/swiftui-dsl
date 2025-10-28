import SwiftUI
import MapLibre

/// An abstraction of the [MLNUserLocationAnnotationViewStyle](https://maplibre.org/maplibre-native/ios/latest/documentation/maplibre/mlnuserlocationannotationviewstyle/)
public struct MapUserAnnotationStyle {
    
    /// The halo border color for the approximate view.
    var approximateHaloBorderColor: Color
    
    /// The halo border width for the approximate view. The default value of this property is equal to 2.0
    var approximateHaloBorderWidth: CGFloat
    
    /// The halo fill color for the approximate view.
    var approximateHaloFillColor: Color
    
    /// The halo opacity for the approximate view. Set any value between 0.0 and 1.0 The default value of this property is equal to 0.15
    var approximateHaloOpacity: CGFloat
    
    /// The fill color for the puck view.
    var haloFillColor: Color
    
    /// The fill color for the arrow puck.
    var puckArrowFillColor: Color
    
    /// The fill color for the puck view.
    var puckFillColor: Color
    
    /// The shadow color for the puck view.
    var puckShadowColor: Color
    
    /// The shadow opacity for the puck view. Set any value between 0.0 and 1.0. The default value of this property is equal to 0.25
    var puckShadowOpacity: CGFloat
    
    /// Create a custom user location annotation style.
    ///
    /// - Parameters:
    ///   - approximateHaloBorderColor: The halo border color for the approximate view.
    ///   - approximateHaloBorderWidth: The halo border width for the approximate view. The default value of this property is equal to 2.0
    ///   - approximateHaloFillColor: The halo fill color for the approximate view.
    ///   - approximateHaloOpacity: The halo opacity for the approximate view. Set any value between 0.0 and 1.0 The default value of this property is equal to 0.15
    ///   - haloFillColor: The fill color for the puck view.
    ///   - puckArrowFillColor: The fill color for the arrow puck.
    ///   - puckFillColor: The fill color for the puck view.
    ///   - puckShadowColor: The shadow color for the puck view.
    ///   - puckShadowOpacity: The shadow opacity for the puck view. Set any value between 0.0 and 1.0. The default value of this property is equal to 0.25
    public init(
        approximateHaloBorderColor: Color = .white,
        approximateHaloBorderWidth: CGFloat = 2.0,
        approximateHaloFillColor: Color = .primary,
        approximateHaloOpacity: CGFloat = 0.15,
        haloFillColor: Color = .primary,
        puckArrowFillColor: Color = .primary,
        puckFillColor: Color = .white,
        puckShadowColor: Color = .black,
        puckShadowOpacity: CGFloat = 0.25
    ) {
        self.approximateHaloBorderColor = approximateHaloBorderColor
        self.approximateHaloBorderWidth = approximateHaloBorderWidth
        self.approximateHaloFillColor = approximateHaloFillColor
        self.approximateHaloOpacity = approximateHaloOpacity
        self.haloFillColor = haloFillColor
        self.puckArrowFillColor = puckArrowFillColor
        self.puckFillColor = puckFillColor
        self.puckShadowColor = puckShadowColor
        self.puckShadowOpacity = puckShadowOpacity
    }
    
}

extension MapUserAnnotationStyle {
    
    /// The MLN value used on the underlying MLNMapView
    var value: MLNUserLocationAnnotationViewStyle {
        let value = MLNUserLocationAnnotationViewStyle()
        value.approximateHaloBorderColor = UIColor(approximateHaloBorderColor)
        value.approximateHaloBorderWidth = approximateHaloBorderWidth
        value.approximateHaloFillColor = UIColor(approximateHaloFillColor)
        value.approximateHaloOpacity = approximateHaloOpacity
        value.haloFillColor = UIColor(haloFillColor)
        value.puckArrowFillColor = UIColor(puckArrowFillColor)
        value.puckFillColor = UIColor(puckFillColor)
        value.puckShadowColor = UIColor(puckShadowColor)
        value.puckShadowOpacity = puckShadowOpacity
        return value
    }
}
