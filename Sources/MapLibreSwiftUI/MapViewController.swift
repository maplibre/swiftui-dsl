//
//  MapViewController.swift
//
//
//  Created by Patrick Kladek on 05.06.24.
//

import UIKit
import MapLibre
import MapboxNavigation
import MapboxCoreNavigation

public protocol WrappedViewController: UIViewController {
	var mapView: MLNMapView { get }
}

public final class MapViewController: UIViewController, WrappedViewController {
	
	public var mapView: MLNMapView {
		return self.view as! MLNMapView
	}
	
	override public func loadView() {
		self.view = MLNMapView(frame: .zero)
	}
}
