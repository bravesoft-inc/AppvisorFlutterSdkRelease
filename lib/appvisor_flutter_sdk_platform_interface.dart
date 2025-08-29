import 'package:appvisor_flutter_sdk/notice_list.dart';
import 'package:appvisor_flutter_sdk/notification_data.dart';
import 'package:appvisor_flutter_sdk/result.dart';
import 'package:appvisor_flutter_sdk/update_data.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'appvisor_flutter_sdk_impl.dart';

abstract class AppvisorFlutterSdkPlatform extends PlatformInterface {
  /// Constructs a AppvisorFlutterSdkPlatform.
  AppvisorFlutterSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static AppvisorFlutterSdkPlatform _instance =
      AppvisorFlutterSdkImpl();

  /// The default instance of [AppvisorFlutterSdkPlatform] to use.
  ///
  /// Defaults to [AppvisorFlutterSdkImpl].
  static AppvisorFlutterSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AppvisorFlutterSdkPlatform] when
  /// they register themselves.
  static set instance(AppvisorFlutterSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> get deviceId {
    throw UnimplementedError('deviceId has not been implemented.');
  }

  Stream<NotificationData> get notificationData {
    throw UnimplementedError('notificationData has not been implemented.');
  }

  Future<Result<Null>> init(String appKey, [bool? enableLogs]) async {
    throw UnimplementedError('init() has not been implemented.');
  }

  Future<bool> get isPushEnabled {
    throw UnimplementedError('isPushEnabled has not been implemented.');
  }

  Future<Result<Null>> configure(
      String channelName, String channelDescription, String smallIconName,
      [String? largeIconName, String? defaultTitle]) {
    throw UnimplementedError('setupNotification() has not been implemented.');
  }

  Future<Result<Map<String, dynamic>>> testNotificationSetup() async {
    throw UnimplementedError(
        'testNotificationSetup() has not been implemented.');
  }

  Future<Result<bool>> togglePush(bool enable) async {
    throw UnimplementedError('togglePush() has not been implemented.');
  }

  Future<bool> setCustomProperty(
      {required int parameterId, String? value}) async {
    throw UnimplementedError('setCustomProperty() has not been implemented.');
  }

  Future<String?> getCustomProperty(int parameterId) async {
    throw UnimplementedError('getCustomProperty() has not been implemented.');
  }

  Future<Result<Null>> syncCustomProperties() async {
    throw UnimplementedError(
        'syncCustomProperties() has not been implemented.');
  }

  Future<Result<UpdateData?>> checkForUpdate(
      {bool? useSDKDialog,
      Function? onDismiss,
      Function? onNavigationToStore}) async {
    throw UnimplementedError('checkForUpdates() has not been implemented.');
  }

  Future<void> requestAppReview() async {
    throw UnimplementedError('requestAppReview() has not been implemented.');
  }

  Future<Result<Map<String, dynamic>>> getConfig() async {
    throw UnimplementedError('getConfig() has not been implemented.');
  }

  Future<Result<NoticeList?>> getNotices([LastKey? lastKey]) async {
    throw UnimplementedError('getNotices() has not been implemented.');
  }

  Future<Result<Null>> markNoticeAsRead(int messageId) async {
    throw UnimplementedError('markNoticeAsRead() has not been implemented.');
  }
}
