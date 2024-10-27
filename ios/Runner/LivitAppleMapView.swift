import Flutter
import UIKit
import MapKit
import CoreLocation

class LivitAppleMapView: NSObject, FlutterPlatformView, CLLocationManagerDelegate, MKMapViewDelegate {
    private var _view: UIView
    private var mapView: MKMapView!
    private let locationManager = CLLocationManager()
    private var channel: FlutterMethodChannel
    private var selectedAnnotation: MKPointAnnotation?
    
    init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, binaryMessenger messenger: FlutterBinaryMessenger?) {
        _view = UIView(frame: frame)
        // Initialize method channel
        channel = FlutterMethodChannel(name: "LivitAppleMapView_\(viewId)", binaryMessenger: messenger!)
        
        super.init()
        
        // Setup location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        createNativeView()
        setupGestureRecognizer()
    }

    func view() -> UIView {
        return _view
    }

    func createNativeView() {
        mapView = MKMapView(frame: _view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.overrideUserInterfaceStyle = .dark
        
        _view.addSubview(mapView)
        
        // Start updating location
        locationManager.startUpdatingLocation()
    }
    
    private func setupGestureRecognizer() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        mapView.addGestureRecognizer(longPress)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            // Remove previous annotation if it exists
            if let existingAnnotation = selectedAnnotation {
                mapView.removeAnnotation(existingAnnotation)
            }
            
            // Get location from touch point
            let touchPoint = gesture.location(in: mapView)
            let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            // Create new annotation
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "Ubicación seleccionada"
            selectedAnnotation = annotation
            
            mapView.addAnnotation(annotation)
            
            // Send location to Flutter
            let location = [
                "latitude": coordinate.latitude,
                "longitude": coordinate.longitude
            ]
            channel.invokeMethod("locationSelected", arguments: location)
        }
    }
    
    // CLLocationManagerDelegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        mapView.setRegion(region, animated: true)
        
        // Stop updating location after we get the first one
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
    
    // MKMapViewDelegate methods
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't customize user location blue dot
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "CustomPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
}
