import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    var flutter_native_splash = 1
    UIApplication.shared.isStatusBarHidden = false

    GeneratedPluginRegistrant.register(with: self)
    GMSServices.provideAPIKey("AIzaSyD3e3F8wOwsHFyPiBRK6pjzT6gxbDsp-oU")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}