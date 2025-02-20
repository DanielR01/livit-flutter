import UIKit
import Flutter
import CoreLocation
import FirebaseCore
import FirebaseAppCheck

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        
        #if DEBUG
            let debugToken = "C13647D7-313C-4A4F-ABEF-776BB2B8FCB9"
            let providerFactory = AppCheckDebugProviderFactory(debugToken: debugToken)
        #else
            let providerFactory = DeviceCheckProviderFactory()
        #endif

        AppCheck.setAppCheckProviderFactory(providerFactory)
        
        guard let controller = window?.rootViewController as? FlutterViewController else {
            fatalError("rootViewController is not type FlutterViewController")
        }
        
        guard let promptRegistrar = controller.registrar(forPlugin: "LivitAppleMapPrompt") else {
            fatalError("Failed to retrieve registrar for LivitAppleMapPrompt")
        }

        guard let viewerRegistrar = controller.registrar(forPlugin: "LivitAppleMapViewer") else {
            fatalError("Failed to retrieve registrar for LivitAppleMapViewer")
        }
        
        let mapPromptFactory = LivitAppleMapPromptFactory(messenger: promptRegistrar.messenger())
        promptRegistrar.register(mapPromptFactory, withId: "LivitAppleMapPrompt")

        let viewerFactory = LivitAppleMapViewerFactory(messenger: viewerRegistrar.messenger())
        viewerRegistrar.register(viewerFactory, withId: "LivitAppleMapViewer")

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
