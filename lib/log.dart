import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';

// ignore: camel_case_types
class log {
  static Future<bool> get _isEnabled async {
    final sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.getBool('enableLogs') ?? false;
  }
  static const String _tag = "AppvisorFlutterSdkFlutter";

  static void i(String msg) async {
    if (kDebugMode && await _isEnabled) {
      developer.log(msg, name: _tag);
    }
  }

  static void e(
    String msg, {
    Object? error,
    StackTrace? stackTrace,
  }) async {
    if (kDebugMode && await _isEnabled) {
      // ANSI escape code for red
      String redStart = "\x1B[31m";
      // ANSI escape code to reset color
      String resetAll = "\x1B[0m";
      developer.log(redStart + msg + resetAll,
          name: _tag, error: error, stackTrace: stackTrace);
    }
  }
}
