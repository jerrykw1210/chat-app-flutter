import Flutter
import UIKit
import stream_video_push_notification
import Firebase
import FirebaseMessaging
import CallKit

@main
@objc class AppDelegate: FlutterAppDelegate{

  private var callObserver: CXCallObserver? // Declare the call observer as an instance variable
  private var callKitEventChannel: FlutterMethodChannel? // Declare the event channel

  override func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      FirebaseApp.configure()
      if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
      }
      GeneratedPluginRegistrant.register(with: self)
      // Register for push notifications.
      StreamVideoPKDelegateManager.shared.registerForPushNotifications()

      // Set up the CallKit observer
      callObserver = CXCallObserver()
      callObserver?.setDelegate(self, queue: DispatchQueue.main)
        
      // Set up platform channel to communicate with Flutter
      callKitEventChannel = FlutterMethodChannel(name: "my.com.prochat.chat.callkit", binaryMessenger: registrar(forPlugin: "CallKitPlugin")!.messenger())

      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Handling background notifications
  override func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    // Make sure to call the completion handler
    
    print("[Swift] Received push notification: \(userInfo)")

    if let channel = self.window?.rootViewController as? FlutterViewController {
      let methodChannel = FlutterMethodChannel(name: "my.com.prochat.chat.pushnotifications", binaryMessenger: channel.binaryMessenger)
      
      methodChannel.invokeMethod("onPushNotificationReceived", arguments: userInfo)
    }
    

    completionHandler(.newData)  // or .noData or .failed based on processing
  }
}

extension AppDelegate: CXCallObserverDelegate {
    
    // This method will be called when there's a change in call status
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
      print("[Swift] Call changed: \(call)");
      
        // if call.hasEnded {
        //     // Call ended
        //     callKitEventChannel?.invokeMethod("callEnded", arguments: nil)
        // } else if call.isOutgoing {
        //     // Outgoing call started
        //     callKitEventChannel?.invokeMethod("outgoingCallStarted", arguments: nil)
        // } else {
        //     // Incoming call started
        //     callKitEventChannel?.invokeMethod("incomingCallStarted", arguments: nil)
        // }
    }
}