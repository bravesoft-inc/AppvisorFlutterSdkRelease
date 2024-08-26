import 'package:appvisor_flutter_sdk/log.dart';
import 'package:appvisor_flutter_sdk/notice_list.dart';
import 'package:appvisor_flutter_sdk/notification_data.dart';
import 'package:appvisor_flutter_sdk/platform_method.dart';
import 'package:appvisor_flutter_sdk/flutter_callback.dart';
import 'package:appvisor_flutter_sdk/result.dart';
import 'package:appvisor_flutter_sdk/update_data.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'appvisor_flutter_sdk_platform_interface.dart';

/// An implementation of [AppvisorFlutterSdkPlatform] that uses method channels.
class AppvisorFlutterSdkImpl extends AppvisorFlutterSdkPlatform {
  /// The method channel used to interact with the native platform.
  final _methodChannel = const MethodChannel('appvisor_flutter_sdk');
  final _notificationEventChannel =
      const EventChannel('appvisor_flutter_sdk/notification');

  @override
  Future<String?> get deviceId async {
    final deviceId = await _methodChannel
        .invokeMethod<String?>(PlatformMethod.GetDeviceId.name);
    return deviceId;
  }

  @override
  Stream<NotificationData> get notificationData {
    return _notificationEventChannel.receiveBroadcastStream().map((event) {
      log.i('Received notification event: $event');
      return NotificationData.fromMap(
          Map<String, String?>.from(event as Map<dynamic, dynamic>));
    });
  }

  @override
  Future<bool> get isPushEnabled async {
    final isPushEnabled = await _methodChannel
        .invokeMethod<bool>(PlatformMethod.IsPushEnabled.name);
    return isPushEnabled ?? false;
  }

  @override
  Future<Result<Null>> init(String appKey, [bool? enableLogs]) async {
    final sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setBool('enableLogs', enableLogs ?? false);
    try {
      await _methodChannel.invokeMethod<void>('Init', <String, dynamic>{
        'appKey': appKey,
        'enableLogs': enableLogs,
      });
      return Result.success(null);
    } on PlatformException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<Null>> configure(
      String channelName, String channelDescription, String smallIconName,
      [String? largeIconName, String? defaultTitle]) async {
    try {
      await _methodChannel
          .invokeMethod<void>(PlatformMethod.Configure.name, <String, dynamic>{
        "setupInfo": {
          'channelName': channelName,
          'channelDescription': channelDescription,
          'smallIconName': smallIconName,
          'largeIconName': largeIconName,
          'defaultTitle': defaultTitle
        }
      });
      return Result.success(null);
    } on PlatformException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> testNotificationSetup() async {
    try {
      final result = await _methodChannel
          .invokeMethod(PlatformMethod.TestNotificationSetup.name);
      return Result.success(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<bool>> togglePush(bool enable) async {
    try {
      final isEnabled = await _methodChannel
          .invokeMethod<bool>(PlatformMethod.TogglePush.name, {'on': enable});
      return Result.success(isEnabled ?? false);
    } on PlatformException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<bool> setCustomProperty(
      {required int parameterId, String? value}) async {
    try {
      final result = await _methodChannel
          .invokeMethod<bool>('SetCustomProperty', <String, dynamic>{
        'parameterId': parameterId,
        'value': value,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      log.e("Failed to set custom property. ${e.message}");
      return false;
    }
  }

  @override
  Future<String?> getCustomProperty(int parameterId) async {
    try {
      final result = await _methodChannel.invokeMethod<String>(
          PlatformMethod.GetCustomProperty.name,
          <String, dynamic>{'parameterId': parameterId});
      return result;
    } on PlatformException catch (e) {
      log.e('Failed to get custom property. ${e.message}');
      return null;
    }
  }

  @override
  Future<Result<Null>> syncCustomProperties() async {
    try {
      await _methodChannel
          .invokeMethod<void>(PlatformMethod.SyncCustomProperties.name);
      return Result.success(null);
    } on PlatformException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<UpdateData?>> checkForUpdate(
      {bool? useSDKDialog,
      Function? onDismiss,
      Function? onNavigationToStore}) async {
    try {
      _methodChannel.setMethodCallHandler((call) async {
        print(call.method);
        if (call.method == FlutterCallback.UpdateDialogOnDismiss.name) {
          onDismiss?.call();
        }
        if (call.method ==
            FlutterCallback.UpdateDialogOnNavigationToStore.name) {
          onNavigationToStore?.call();
        }
      });

      final result = await _methodChannel.invokeMethod<Map<Object?, Object?>>(
          PlatformMethod.CheckForUpdate.name, <String, dynamic>{
        'useSDKDialog': useSDKDialog,
      });
      if (result == null) {
        return Result.success(null);
      } else {
        return Result.success(UpdateData.fromMap(
            Map<String, dynamic>.from(result as Map<dynamic, dynamic>)));
      }
    } on PlatformException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<void> requestAppReview() async {
    try {
      await _methodChannel
          .invokeMethod<void>(PlatformMethod.RequestAppReview.name);
    } on PlatformException catch (e) {
      log.e('Failed to request app review. ${e.message}');
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getConfig() async {
    try {
      final result = await _methodChannel
          .invokeMethod<Map<Object?, Object?>>(PlatformMethod.GetConfig.name);
      return Result.success(
          Map<String, dynamic>.from(result as Map<dynamic, dynamic>));
    } on PlatformException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<NoticeList?>> getNotices([LastKey? lastKey]) async {
    try {
      final result = await _methodChannel.invokeMethod<Map<Object?, Object?>>(
          PlatformMethod.GetNotices.name,
          <String, dynamic>{"lastKey": lastKey?.toMap()});

      final noticeList = NoticeList.fromMap(
          Map<String, dynamic>.from(result as Map<dynamic, dynamic>));
      return Result.success(noticeList);
    } on PlatformException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<Null>> markNoticeAsRead(int messageId) async {
    try {
      await _methodChannel.invokeMethod<void>(
          PlatformMethod.MarkNoticeAsRead.name, <String, dynamic>{
        'messageId': messageId,
      });
      return Result.success(null);
    } on PlatformException catch (e) {
      return Result.failure(e);
    }
  }
}
