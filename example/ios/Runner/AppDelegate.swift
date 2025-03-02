import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "google_geofence_helper",
                                     binaryMessenger: controller.binaryMessenger)
    
    channel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "getGoogleMapsApiKey" {
        if let args = call.arguments as? [String: Any],
           let apiKey = args["apiKey"] as? String {
          GMSServices.provideAPIKey(apiKey)
          result(true)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENTS",
                            message: "API key not provided",
                            details: nil))
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
