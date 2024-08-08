import MapLibre
import UIKit

public protocol MapViewHostViewController: UIViewController {
    associatedtype MapType: MLNMapView
    @MainActor var mapView: MapType { get }
}

public final class MLNMapViewController: UIViewController, MapViewHostViewController {
    @MainActor
    public var mapView: MLNMapView {
        view as! MLNMapView
    }

    override public func loadView() {
        view = MLNMapView(frame: .zero)
    }
}
