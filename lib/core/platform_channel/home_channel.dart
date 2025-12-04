import 'package:flutter/services.dart';

class HomeChannel {
  static const MethodChannel _channel = MethodChannel('tuya_home');

  /// Get list of all homes
  static Future<List<Map<String, dynamic>>> getHomeList() async {
    try {
      final result = await _channel.invokeMethod('getHomeList');
      if (result is List) {
        return result.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } on PlatformException catch (e) {
      throw Exception('Failed to get home list: ${e.message}');
    }
  }

  /// Create a new home
  static Future<int> createHome({
    required String name,
    String geoName = '',
    double latitude = 0.0,
    double longitude = 0.0,
    List<String> rooms = const [],
  }) async {
    try {
      final result = await _channel.invokeMethod('createHome', {
        'name': name,
        'geoName': geoName,
        'latitude': latitude,
        'longitude': longitude,
        'rooms': rooms,
      });
      return result as int;
    } on PlatformException catch (e) {
      throw Exception('Failed to create home: ${e.message}');
    }
  }

  /// Delete a home
  static Future<void> deleteHome({required int homeId}) async {
    try {
      await _channel.invokeMethod('deleteHome', {'homeId': homeId});
    } on PlatformException catch (e) {
      throw Exception('Failed to delete home: ${e.message}');
    }
  }

  /// Update home name
  static Future<void> updateHomeName({
    required int homeId,
    required String name,
  }) async {
    try {
      await _channel.invokeMethod('updateHomeName', {
        'homeId': homeId,
        'name': name,
      });
    } on PlatformException catch (e) {
      throw Exception('Failed to update home name: ${e.message}');
    }
  }

  /// Get home details
  static Future<Map<String, dynamic>> getHomeDetail({
    required int homeId,
  }) async {
    try {
      final result = await _channel.invokeMethod('getHomeDetail', {
        'homeId': homeId,
      });
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw Exception('Failed to get home details: ${e.message}');
    }
  }
}
