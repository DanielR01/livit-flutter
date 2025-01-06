import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LocationSearchService {
  static const String _channelName = "LivitLocationSearch";
  static const MethodChannel _channel = MethodChannel(_channelName);

  static Future<Map<String, double>> searchLocation(String address) async {
    try {
      debugPrint('🔍 [LocationSearchService] Searching location for address: $address');
      final result = await _channel.invokeMethod('searchLocation', address);
      debugPrint('🔍 [LocationSearchService] Result: $result');
      if (result != null) {
        final Map<dynamic, dynamic> locationData = result;
        return {
          'latitude': locationData['latitude'] as double,
          'longitude': locationData['longitude'] as double,
        };
      }
      throw Exception('No location data received');
    } on PlatformException catch (e) {
      throw Exception(e.message);
    }
  }
}
