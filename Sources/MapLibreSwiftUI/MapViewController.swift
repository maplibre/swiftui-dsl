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

public final class MapViewController: UIViewController {
	
	var mapView: MLNMapView {
		return self.view as! MLNMapView
	}
	
	override public func loadView() {
		self.view = MLNMapView(frame: .zero)
	}
}
