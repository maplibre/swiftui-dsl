import XCTest
import MockableTest
import CoreLocation
@testable import MapLibreSwiftUI

final class MapViewCoordinatorCameraTests: XCTestCase {

    var maplibreMapView: MockMLNMapViewCamera!
    var mapView: MapView!
    var coordinator: MapView.Coordinator!
    
    override func setUp() async throws {
        maplibreMapView = MockMLNMapViewCamera()
        mapView = MapView(styleURL: URL(string: "https://maplibre.org")!)
        coordinator = MapView.Coordinator(parent: mapView) { _, _ in
            // No action
        }
    }
    
    func testUnchangedCamera() {
        let camera: MapViewCamera = .default()
        
        coordinator.updateCamera(mapView: maplibreMapView, camera: camera, animated: false)
        // Run a second update.
        coordinator.updateCamera(mapView: maplibreMapView, camera: camera, animated: false)
        
        // Note all of the actions only allow 1 count of set even though we've run the action
        // twice.
        verify(maplibreMapView)
            .userTrackingMode(newValue: .value(.none))
            .setterCalled(count: 1)
        
        verify(maplibreMapView)
            .setCenter(.value(MapViewCamera.Defaults.coordinate),
                       zoomLevel: .value(10),
                       direction: .value(0),
                       animated: .value(false))
            .called(count: 1)
        
        verify(maplibreMapView)
            .minimumPitch(newValue: .value(0))
            .setterCalled(count: 1)
        
        verify(maplibreMapView)
            .maximumPitch(newValue: .value(60))
            .setterCalled(count: 1)
        
        verify(maplibreMapView)
            .setZoomLevel(.any, animated: .any)
            .called(count: 0)
    }
    
    func testCenterCameraUpdate() {
        let coordinate = CLLocationCoordinate2D(latitude: 12.3, longitude: 23.4)
        let newCamera: MapViewCamera = .center(coordinate, zoom: 13)
        
        coordinator.updateCamera(mapView: maplibreMapView, camera: newCamera, animated: false)
        
        verify(maplibreMapView)
            .userTrackingMode(newValue: .value(.none))
            .setterCalled(count: 1)
        
        verify(maplibreMapView)
            .setCenter(.value(coordinate),
                       zoomLevel: .value(13),
                       direction: .value(0),
                       animated: .value(false))
            .called(count: 1)
        
        verify(maplibreMapView)
            .minimumPitch(newValue: .value(0))
            .setterCalled(count: 1)
        
        verify(maplibreMapView)
            .maximumPitch(newValue: .value(60))
            .setterCalled(count: 1)
        
        verify(maplibreMapView)
            .setZoomLevel(.any, animated: .any)
            .called(count: 0)
    }
    
    func testUserTrackingCameraUpdate() {
        let newCamera: MapViewCamera = .trackUserLocation()
        
        coordinator.updateCamera(mapView: maplibreMapView, camera: newCamera, animated: false)
        
        verify(maplibreMapView)
            .userTrackingMode(newValue: .value(.follow))
            .setterCalled(count: 1)
        
        verify(maplibreMapView)
            .setCenter(.any,
                       zoomLevel: .any,
                       direction: .any,
                       animated: .any)
            .called(count: 0)
        
        verify(maplibreMapView)
            .minimumPitch(newValue: .value(0))
            .setterCalled(count: 1)
        
        verify(maplibreMapView)
            .maximumPitch(newValue: .value(60))
            .setterCalled(count: 1)
        
        verify(maplibreMapView)
            .setZoomLevel(.value(10), animated: .value(false))
            .called(count: 1)
    }
    
    func testUserTrackingWithCourseCameraUpdate() {
        let newCamera: MapViewCamera = .trackUserLocationWithCourse()
        
        coordinator.updateCamera(mapView: maplibreMapView, camera: newCamera, animated: false)
        
        verify(maplibreMapView)
            .userTrackingMode(newValue: .value(.followWithCourse))
            .setterCalled(count: 1)
        
        verify(maplibreMapView)
            .setCenter(.any,
                       zoomLevel: .any,
                       direction: .any,
                       animated: .any)
            .called(count: 0)
        
        verify(maplibreMapView)
            .minimumPitch(newValue: .value(0))
            .setterCalled(count: 1)
        
        verify(maplibreMapView)
            .maximumPitch(newValue: .value(60))
            .setterCalled(count: 1)
        
        verify(maplibreMapView)
            .setZoomLevel(.value(10), animated: .value(false))
            .called(count: 1)
    }
    
    func testUserTrackingWithHeadingUpdate() {
        let newCamera: MapViewCamera = .trackUserLocationWithHeading()
        
        coordinator.updateCamera(mapView: maplibreMapView, camera: newCamera, animated: false)
        
        verify(maplibreMapView)
            .userTrackingMode(newValue: .value(.followWithHeading))
            .setterCalled(count: 1)
        
        verify(maplibreMapView)
            .setCenter(.any,
                       zoomLevel: .any,
                       direction: .any,
                       animated: .any)
            .called(count: 0)
        
        verify(maplibreMapView)
            .minimumPitch(newValue: .value(0))
            .setterCalled(count: 1)
        
        verify(maplibreMapView)
            .maximumPitch(newValue: .value(60))
            .setterCalled(count: 1)
        
        verify(maplibreMapView)
            .setZoomLevel(.value(10), animated: .value(false))
            .called(count: 1)
    }
 
    // TODO: Test Rect & Showcase once we build it!
    
}
