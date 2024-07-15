import MapLibre
import UIKit

public protocol MapViewHostViewController: UIViewController {
    associatedtype MapType: MLNMapView
    var mapView: MapType { get }
}

public final class MLNMapViewController: UIViewController, MapViewHostViewController {
    public var mapView: MLNMapView {
        view as! MLNMapView
    }

    override public func loadView() {
        view = MLNMapView(frame: .zero)
    }
}
