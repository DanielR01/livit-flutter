import UIKit
import Flutter
import CoreLocation

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        guard let controller = window?.rootViewController as? FlutterViewController else {
            fatalError("rootViewController is not type FlutterViewController")
        }
        
        guard let registrar = controller.registrar(forPlugin: "LivitAppleMapView") else {
            fatalError("Failed to retrieve registrar for LivitAppleMapView")
        }
        
        let mapViewFactory = LivitAppleMapViewFactory(messenger: registrar.messenger())
        registrar.register(mapViewFactory, withId: "LivitAppleMapView")

        // Register location search service
        let locationSearchChannel = FlutterMethodChannel(
            name: "LivitLocationSearch",
            binaryMessenger: controller.binaryMessenger
        )
        
        let locationSearchService = LocationSearchService()
        
        locationSearchChannel.setMethodCallHandler { call, result in
            if call.method == "searchLocation" {
                guard let address = call.arguments as? String else {
                    result(FlutterError(code: "INVALID_ARGUMENT",
                                      message: "Address must be a string",
                                      details: nil))
                    return
                }
                
                locationSearchService.searchLocation(address: address) { searchResult in
                    switch searchResult {
                    case .success(let coordinates):
                        result([
                            "latitude": coordinates.latitude,
                            "longitude": coordinates.longitude
                        ])
                    case .failure(let error):
                        result(FlutterError(code: "SEARCH_ERROR",
                                          message: error.localizedDescription,
                                          details: nil))
                    }
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
