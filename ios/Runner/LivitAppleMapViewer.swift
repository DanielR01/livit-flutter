import Flutter
import UIKit
import MapKit
import CoreLocation

class LivitAppleMapViewer: NSObject, FlutterPlatformView, CLLocationManagerDelegate, MKMapViewDelegate {
    private var _view: UIView
    private var mapView: MKMapView!
    private let locationManager = CLLocationManager()
    private var channel: FlutterMethodChannel
    private var selectedAnnotation: MKPointAnnotation?
    private let geocoder = CLGeocoder()
    
    init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, binaryMessenger messenger: FlutterBinaryMessenger?) {
        _view = UIView(frame: frame)
        
        channel = FlutterMethodChannel(name: "LivitAppleMapViewer_\(viewId)", binaryMessenger: messenger!)
        
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        createNativeView()
        setupMethodChannel()
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
        
        locationManager.startUpdatingLocation()
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
    
    private func setupMethodChannel() {
        print("iOS: Setting up method channel")
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { return }
            print("iOS: Received method call: \(call.method)")
            
            switch call.method {
            case "setLocation":
                if let args = call.arguments as? [String: Any],
                   let latitude = args["latitude"] as? Double,
                   let longitude = args["longitude"] as? Double,
                   let title = args["title"] as? String {
                    self.setLocation(latitude: latitude, longitude: longitude, title: title)
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS",
                                      message: "Invalid location arguments",
                                      details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    private func setLocation(latitude: Double, longitude: Double, title: String) {
        // Remove previous annotation if it exists
        if let existingAnnotation = selectedAnnotation {
            mapView.removeAnnotation(existingAnnotation)
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        // Create new annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        selectedAnnotation = annotation
        
        // Add annotation and center map with animation
        mapView.addAnnotation(annotation)
        
        // Set a slightly larger region to show context around the pin
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        // Animate to the new region
        mapView.setRegion(region, animated: true)
        
        // After a short delay, zoom in closer to the pin
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let closeSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let closeRegion = MKCoordinateRegion(center: coordinate, span: closeSpan)
            self.mapView.setRegion(closeRegion, animated: true)
        }
    }
}
