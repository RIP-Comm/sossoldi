import UIKit
import Flutter
import flutter_local_notifications
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
		// This is required to make any communication available in the action isolate.
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
        GeneratedPluginRegistrant.register(with: registry)
    }

    var googleApiKey: String?
    
    #if DEBUG
    googleApiKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_API_KEY") as? String
    #endif
    
    if googleApiKey == nil {
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
           let plist = NSDictionary(contentsOfFile: path) {
            googleApiKey = plist["GOOGLE_API_KEY"] as? String
        }
    }
    
    if let apiKey = googleApiKey, !apiKey.isEmpty && apiKey != "$(GOOGLE_API_KEY)" {
        GMSServices.provideAPIKey(apiKey)
    } else {
        print("Warning: GOOGLE_API_KEY not found or empty")
    } 

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
