import MapLibre
import UIKit

public protocol MapViewHostViewController: UIViewController {
    associatedtype MapType: MLNMapView
    @MainActor var mapView: MapType { get }
}

public final class MLNMapViewController: UIViewController, MapViewHostViewController {
    let activity: MapActivity
    /// The bootstrap style used when constructing the underlying MLNMapView.
    /// Runtime style changes happen via `mapView.styleURL` from SwiftUI updates.
    let initialStyleURL: URL

    public init(initialStyleURL: URL, activity: MapActivity = .standard) {
        self.initialStyleURL = initialStyleURL
        self.activity = activity
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @MainActor
    public var mapView: MLNMapView {
        view as! MLNMapView
    }

    /// Called after layout changes the map's size.
    var onSizeChange: (() -> Void)?
    private var laidOutSize: CGSize = .zero

    override public func loadView() {
        view = MLNMapView(frame: .zero, styleURL: initialStyleURL)
        view.tag = activity.rawValue
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard view.bounds.size != laidOutSize else { return }
        laidOutSize = view.bounds.size
        onSizeChange?()
    }
}
