import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    weak var registrar = self.registrar(forPlugin: "my-views")
    let appleMapViewFactory = LivitAppleMapViewFactory(messenger: registrar!.messenger())
    let viewRegistrar = self.registrar(forPlugin: "<my-views>")!
    viewRegistrar.register(appleMapViewFactory, withId: "LivitAppleMapView")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
