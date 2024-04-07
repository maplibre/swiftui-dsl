import Foundation
import MapLibre

public protocol MapControl {
    /// Overrides the position of the control. Default values are control-specfiic.
    var position: MLNOrnamentPosition? { get set }
    /// Overrides the offset of the control.
    var margins: CGPoint? { get set }
    /// Overrides whether the control is hidden.
    var isHidden: Bool { get set }

    @MainActor func configureMapView(_ mapView: MLNMapView)
}

public extension MapControl {
    /// Sets position of the control.
    func position(_ position: MLNOrnamentPosition) -> Self {
        var result = self

        result.position = position

        return result
    }

    /// Sets the position offset of the control.
    func margins(_ margins: CGPoint) -> Self {
        var result = self

        result.margins = margins

        return result
    }

    /// Hides the control.
    func hidden(_: Bool) -> Self {
        var result = self

        result.isHidden = true

        return result
    }
}

public struct CompassView: MapControl {
    public var position: MLNOrnamentPosition?
    public var margins: CGPoint?
    public var isHidden: Bool = false

    public func configureMapView(_ mapView: MLNMapView) {
        if let position {
            mapView.compassViewPosition = position
        }

        if let margins {
            mapView.compassViewMargins = margins
        }

        mapView.compassView.isHidden = isHidden
    }

    public init() {}
}

public struct LogoView: MapControl {
    public var position: MLNOrnamentPosition?
    public var margins: CGPoint?
    public var isHidden: Bool = false
    public var image: UIImage?

    public init() {}

    public func configureMapView(_ mapView: MLNMapView) {
        if let position {
            mapView.logoViewPosition = position
        }

        if let margins {
            mapView.logoViewMargins = margins
        }

        mapView.logoView.isHidden = isHidden

        if let image {
            mapView.logoView.image = image
        }
    }
}

public extension LogoView {
    /// Sets the logo image (defaults to the MapLibre logo).
    func image(_ image: UIImage?) -> Self {
        var result = self

        result.image = image

        return result
    }
}

public struct AttributionButton: MapControl {
    public var position: MLNOrnamentPosition?
    public var margins: CGPoint?
    public var isHidden: Bool = false

    public func configureMapView(_ mapView: MLNMapView) {
        if let position {
            mapView.attributionButtonPosition = position
        }

        if let margins {
            mapView.attributionButtonMargins = margins
        }

        mapView.attributionButton.isHidden = isHidden
    }

    public init() {}
}

@resultBuilder
public enum MapControlsBuilder: DefaultResultBuilder {
    public static func buildExpression(_ expression: MapControl) -> [MapControl] {
        [expression]
    }

    public static func buildExpression(_ expression: [MapControl]) -> [MapControl] {
        expression
    }

    public static func buildExpression(_: Void) -> [MapControl] {
        []
    }

    public static func buildBlock(_ components: [MapControl]...) -> [MapControl] {
        components.flatMap { $0 }
    }

    public static func buildArray(_ components: [MapControl]) -> [MapControl] {
        components
    }

    public static func buildArray(_ components: [[MapControl]]) -> [MapControl] {
        components.flatMap { $0 }
    }

    public static func buildEither(first components: [MapControl]) -> [MapControl] {
        components
    }

    public static func buildEither(second components: [MapControl]) -> [MapControl] {
        components
    }

    public static func buildOptional(_ components: [MapControl]?) -> [MapControl] {
        components ?? []
    }
}
