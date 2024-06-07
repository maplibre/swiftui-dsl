import MapLibre
import UIKit

public protocol WrappedViewController: UIViewController {
    associatedtype MapType: MLNMapView
    var mapView: MapType { get }
}

public final class MapViewController: UIViewController, WrappedViewController {
    public var mapView: MLNMapView {
        view as! MLNMapView
    }

    override public func loadView() {
        view = MLNMapView(frame: .zero)
    }
}
