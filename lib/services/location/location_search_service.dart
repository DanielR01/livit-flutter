import 'package:flutter/services.dart';

class LocationSearchService {
  static const String _channelName = "LivitLocationSearch";
  static const MethodChannel _channel = MethodChannel(_channelName);

  static Future<Map<String, double>> searchLocation(String address) async {
    try {
      print('address: $address');
      final result = await _channel.invokeMethod('searchLocation', address);
      print('result: $result');
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
