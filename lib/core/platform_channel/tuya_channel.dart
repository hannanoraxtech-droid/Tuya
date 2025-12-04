import 'package:flutter/services.dart';

class TuyaChannel {
  static const MethodChannel _channel = MethodChannel('tuya_auth');

  static Future<void> sendEmailCode(String email, {int type = 1}) async {
    await _channel.invokeMethod('sendEmailCode', {
      "email": email,
      "type": type,
    });
  }

  static Future<void> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    await _channel.invokeMethod('resetEmailPassword', {
      "email": email,
      "code": code,
      "password": newPassword,
    });
  }

  static Future<void> registerAccount(
    String email,
    String code,
    String password,
  ) async {
    await _channel.invokeMethod('registerEmail', {
      "email": email,
      "code": code,
      "password": password,
    });
  }

  static Future<void> login(String email, String password) async {
    await _channel.invokeMethod('loginEmail', {
      "email": email,
      "password": password,
    });
  }

  static Future<String> testNetwork() async {
    try {
      final result = await _channel.invokeMethod('testNetwork');
      return result.toString();
    } catch (e) {
      return "Network Test Failed: $e";
    }
  }

  static Future<bool> isLogin() async {
    try {
      final result = await _channel.invokeMethod('isLogin');
      return result as bool;
    } catch (e) {
      return false;
    }
  }

  static Future<void> logout() async {
    await _channel.invokeMethod('logout');
  }
}
