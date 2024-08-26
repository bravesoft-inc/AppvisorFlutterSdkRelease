import Flutter
import UIKit
import AppVisorSDK

let avp = Appvisor.sharedInstance
fileprivate let tag = "AppvisorFlutterPlugin"

public class AppvisorFlutterSdkPlugin: NSObject, FlutterPlugin {
    private let userDefaults = UserDefaults.standard
    
    let notifStream: NotificationStream
    
    private let channel: FlutterMethodChannel
    
    init(notifStream: NotificationStream, channel: FlutterMethodChannel) {
        self.notifStream = notifStream
        self.channel = channel
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        log(tag, "Registering the plugin.")
        let channel = FlutterMethodChannel(name: "appvisor_flutter_sdk", binaryMessenger: registrar.messenger())
        
        let notifStream = NotificationStream()
        let notificationEventChannel = FlutterEventChannel(name: "appvisor_flutter_sdk/notification", binaryMessenger: registrar.messenger())
        notificationEventChannel.setStreamHandler(notifStream)
        
        let instance = AppvisorFlutterSdkPlugin(notifStream: notifStream, channel: channel)
        
        registrar.addApplicationDelegate(instance)
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        log(tag, "Registeration is finished.")
    }
    

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let method = PlatformMethod(rawValue: call.method)
        
        switch method {
        case .GetDeviceId:
            result(Appvisor.appvisorUDID())
        case .IsPushEnabled:
            result(avp.canReceivePush())
        case .Configure:
            result(nil)
        case .Init:
            initAvp(call, result)
        case .TogglePush:
            handleTogglePush(call, result)
        case .RequestAppReview:
            handleRequestAppReview(result)
        case .SetCustomProperty:
            handleSetCustomProperty(call, result) 
        case .GetCustomProperty:
            hanldeGetCustomProperty(call, result)
        case .SyncCustomProperties:
            handleSyncCustomProperties(call, result)
        case .GetNotices:
            handleGetNotices(call, result)
        case .GetConfig:
            handleGetConfig(result)
        case .CheckForUpdate:
            handleCheckForUpdate(call, result)
        case .MarkNoticeAsRead:
            handleMarkNoteiceAsRead(call, result)
        default:
            result(FlutterMethodNotImplemented)
        }
        log(tag, "Method: \(method?.rawValue ?? "Unknown")")
    }
    
    private func initAvp(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let args = call.arguments as! Dictionary<String, Any>
        let enableLogs = args["enableLogs"] as? Bool ?? false
        userDefaults.set(enableLogs, forKey: "enableLogs")
        
        guard let appKey = args["appKey"] as? String,
              !appKey.isEmpty else {
            log(tag, "Missing required argument: appKey")
            // return an error when the appKey is missing
            return result(FlutterError(
                code: AvpError.MissingRequiredArg.rawValue,
                message: missingArgs("appKey"),
                details: nil)
            )
        }

        log(tag, "AppVisorPush initialized with appKey: \(appKey.prefix(appKey.count - 5))*****")
        // Looks like this function will request notification permission and call the register api.
        // But since it doesn't any returns anything, there's no way to know if the user has granted the permission or not.

        avp.enablePush(with: appKey, isDebug: enableLogs)
        return result(nil)
    }
    
    private func requestNotificationAuthorization(
       action: @escaping (Bool, Error?) -> Void
    ) {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]

        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
            action(granted, error)
        }
    }

    private func handleTogglePush(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? Dictionary<String, Any>,
              let enable = args["on"] as? Bool else {
            log(tag, "Missing required argument: on")
            return result(FlutterError(
                code: AvpError.MissingRequiredArg.rawValue,
                message: missingArgs("on"),
                details: nil)
            )
        }
        avp.setPushStatus(enable, completion: {newStatus in
            log(tag, "Push status changed to: \(newStatus)")
            result(enable)
        })
    }
    
    private func handleRequestAppReview(_ result: @escaping FlutterResult) {
        Appvisor.requestAppReview(completion: {_,error in
            if let error = error {
                log(tag, "Request app review failed: \(error.localizedDescription)")
                result(FlutterError(
                    code: AvpError.RequestAppReviewFailed.rawValue,
                    message: error.localizedDescription,
                    details: nil)
                )
            } else {
                log(tag, "Request app review succeeded.")
                result(nil)
            }
        })
    }
    
    private func handleSetCustomProperty(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? Dictionary<String, Any>,
              let id = args["parameterId"] as? Int else {
            log(tag, "Missing required argument: parameterId")
            
            return result(FlutterError(
                code: AvpError.MissingRequiredArg.rawValue,
                message: missingArgs("parameterId"),
                details: nil)
            )
        }
        
        let value = args["value"] as? String
        let success = avp.setUserProperty(value, forGroup: id)
        log(tag, "Set custom property with id: \(id) and value: \(String(describing: value))")
        result(success)
    }
    
    
    private func hanldeGetCustomProperty(_ call: FlutterMethodCall, _ result: FlutterResult) {
        guard let args = call.arguments as? Dictionary<String, Any>,
              let id = args["parameterId"] as? Int else {
            log(tag, "Missing required argument: parameterId")
            return result(FlutterError(
                code: AvpError.MissingRequiredArg.rawValue,
                message: missingArgs("parameterId"),
                details: nil)
            )
        }
        let value = avp.getUserProperty(forGroup: id)
        log(tag, "Get custom property with id: \(id) and value: \(String(describing: value))")
        result(value)
    }

    private func handleSyncCustomProperties(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        log(tag, "Syncing user properties.")
        avp.synchronizeUserProperties()
        log(tag, "User properties synced.")
        result(nil)
    }

    private func handleGetNotices(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let args = call.arguments as? Dictionary<String, Any>
        let lastKey = args?["lastKey"] as? Dictionary<String, String>
        let messageId = lastKey?["messageId"]
        let userUUID = lastKey?["userUUID"]
        avp.getNotices(with: messageId, and: userUUID, completion: {response in
            result(response?.toMap() ?? [:])
        })
    }
    
    private func handleGetConfig(_ result: @escaping FlutterResult) {
        avp.getCurrentConfig(completion: {config in
            if let config = config {
               result(config.toMap())
            }
        })
    }
    
    private func handleCheckForUpdate(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let args = call.arguments as? Dictionary<String, Any>
        let useSDKDialog = args?["useSDKDialog"] as? Bool ?? true
        avp.checkForUpdate(useSDKDialog: useSDKDialog, onCancel: {
            self.channel
                .invokeMethod(FlutterCallback.UpdateDialogOnDismiss.rawValue, arguments: nil)
        }, onUpdate: {
            self.channel
                .invokeMethod(FlutterCallback.UpdateDialogOnNavigationToStore.rawValue, arguments: nil)
        }, completion: { r in
            switch r {
            case .success(let response):
                log(tag, "Check for update succeeded: \(response)")
                result(response.toMap())
            case .failure(let error):
                log(tag, "Check for update failed: \(error.localizedDescription)")
                result(FlutterError(
                    code: AvpError.CheckForUpdateFailed.rawValue,
                    message: error.localizedDescription,
                    details: nil)
                )
            }
        })
    }
    
    private func handleMarkNoteiceAsRead(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? Dictionary<String, Any>,
              let messageId = args["messageId"] as? Int else {
            log(tag, "Missing required argument: messageId")
            return result(FlutterError(
                code: AvpError.MissingRequiredArg.rawValue,
                message: missingArgs("messageId"),
                details: nil)
            )
        }
        avp.setNoticeRead(with: messageId)
        result(nil)
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        let userInfo = launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: Any]
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        avp.trackPush(with: userInfo)
        return true
    }
    
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // The enablePush() function changes the notification center delegate.
        // It causes problems with receiving the push notification.
        // Refer to the related issue for more details.
        // https://github.com/dpa99c/cordova-plugin-firebasex/pull/800
        log(tag, "Device token received.\nReassigning the UNUserNotificationCenter delegate to self.")
        UNUserNotificationCenter.current().delegate = self         
        avp.registerToken(with: deviceToken)
    }
    
    public func applicationWillEnterForeground(_ application: UIApplication) {
        avp.clearBadgeNumber()
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        log(tag, "Push notification received in foreground.")
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let notification = response.notification
        let title = notification.request.content.title
        let body = notification.request.content.body
        let userInfo = notification.request.content.userInfo
        
        var trackingInfo: [String: Any] = userInfo.reduce(into: [:]) { (result, element) in
            if let key = element.key as? String {
                result[key] = element.value
            }
        }
        
        trackingInfo["title"] = title
        trackingInfo["body"] = body
        
        let notifData = [
            "title": title,
            "message": body,
            "w": trackingInfo["w"],
            "x": trackingInfo["x"],
            "y": trackingInfo["y"],
            "z": trackingInfo["z"]
        ]
        self.notifStream.send(event: notifData)
        
        avp.trackPush(with: trackingInfo)
        
        completionHandler()
    }
    
    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        log(tag, "Error in registration. Error: \(error)")
    }
}
