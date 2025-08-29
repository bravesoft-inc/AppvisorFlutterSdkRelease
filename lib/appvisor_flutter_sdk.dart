import 'package:appvisor_flutter_sdk/notice_list.dart';
import 'package:appvisor_flutter_sdk/notification_data.dart';
import 'package:appvisor_flutter_sdk/result.dart';
import 'package:appvisor_flutter_sdk/update_data.dart';
import 'package:flutter/foundation.dart';

import 'appvisor_flutter_sdk_platform_interface.dart';

class AppvisorFlutterSdk {
  final platform = AppvisorFlutterSdkPlatform.instance;

  /// Asynchronously retrieves the device ID.
  ///
  /// This method returns a [Future] that completes with the device ID as a [String] from the platform.
  /// If the device ID cannot be obtained, the [Future] completes with [null].
  Future<String?> get deviceId {
    return platform.deviceId;
  }

  /// Asynchronously checks if push notifications are enabled.
  ///
  /// This method returns a [Future] that completes with a boolean value.
  /// The value is obtained from the platform's [isPushEnabled] property.
  Future<bool> get isPushEnabled {
    return platform.isPushEnabled;
  }
 
  /// A stream of [NotificationData] objects.
  /// 
  /// This stream emits [NotificationData] objects when a push notification is received.
  Stream<NotificationData> get notificationData {
    return platform.notificationData;
  }

  /// Initializes the Appvisor Push SDK.
  ///
  /// NOTE: YOU MUST FIRST CALL THE `configure` METHOD BEFORE CALLING THIS METHOD.
  ///
  /// This method initializes the Appvisor Push SDK with the provided [appKey] and [enableLogs] parameters.
  /// The [appKey] parameter is a [String] that represents the Appvisor Push SDK key.
  /// The [enableLogs] parameter is a [bool] that determines whether logs are enabled.
  ///
  /// This method returns a [Future] that completes with a [Result] object.
  /// If the initialization is successful, the [Result] object contains a [null] value which can be ignored.
  /// If the initialization fails, the [Result] object contains an [AvpError] object.
  Future<Result<Null>> init(String appKey, [bool? enableLogs]) async {
    return platform.init(appKey, enableLogs);
  }

  /// Sets up the notification channel for the push notification service.
  ///
  /// The [channelName] parameter specifies the name of the notification channel.
  /// The [channelDescription] parameter specifies the description of the notification channel.
  /// The [smallIconName] parameter specifies the name of the small icon to be used for the notification.
  /// The [largeIconName] parameter specifies the name of the large icon to be used for the notification (optional).
  /// The [defaultTitle] parameter specifies the default title for the notification (optional).
  ///
  /// Returns a [Future] that completes with a [Result] object containing a [Null] value.
  Future<Result<Null>> configure(
      {required String channelName,
      required String channelDescription,
      required String smallIconName,
      String? largeIconName,
      String? defaultTitle}) {
    return platform.configure(channelName, channelDescription, smallIconName,
        largeIconName, defaultTitle);
  }

  @visibleForTesting
  Future<Result<Map<String, dynamic>>> testNotificationSetup() async {
    return platform.testNotificationSetup();
  }

  /// Toggles push notifications on or off.
  ///
  /// The [enable] parameter specifies whether to enable or disable push notifications.
  ///
  /// Returns a [Future] that completes with a [Result] object containing a [bool] value, which is `true` if push notifications are enabled, and `false` if they are disabled.
  Future<Result<bool>> togglePush(bool enable) async {
    return platform.togglePush(enable);
  }

  /// Sets the value for provided parameter id.
  ///
  /// This function sets the provided [value] for the specified [parameterId].
  ///
  /// [value] The value to be set for the parameter id. Set null to delete the property.
  /// [parameterId] The parameter id for which the value should be set.
  ///
  /// Returns `true` if the value is successfully set or removed, `false` otherwise.
  Future<bool> setCustomProperty({required parameterId, String? value}) {
    return platform.setCustomProperty(parameterId: parameterId, value: value);
  }

  /// Gets the value for provided parameter id.
  ///
  /// This function gets the value for the specified [parameterId].
  ///
  /// [parameterId] The parameter id for which the value should be retrieved.
  ///
  /// Returns the value for the specified parameter id.
  Future<String?> getCustomProperty(int parameterId) {
    return platform.getCustomProperty(parameterId);
  }

  /// Synchronizes the custom properties with the server.
  Future<Result<Null>> syncCustomProperties() {
    return platform.syncCustomProperties();
  }

  Future<Result<UpdateData?>> checkForUpdates(
      {bool? useSDKDialog,
      Function? onDismiss,
      Function? onNavigationToStore}) {
    return platform.checkForUpdate(
        useSDKDialog: useSDKDialog,
        onDismiss: onDismiss,
        onNavigationToStore: onNavigationToStore
        );
  }

  Future<void> requestAppReview() {
    return platform.requestAppReview();
  }

  Future<Result<Map<String, dynamic>>> getConfig() {
    return platform.getConfig();
  }

  Future<Result<NoticeList?>> getNotices([LastKey? lastKey]) {
    return platform.getNotices(lastKey);
  }

  Future<Result<Null>> markNoticeAsRead(int messageId) async {
    return platform.markNoticeAsRead(messageId);
  }
}
