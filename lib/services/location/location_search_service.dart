import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';

class LocationSearchService {
  static const String _channelName = "LivitLocationSearch";
  static const MethodChannel _channel = MethodChannel(_channelName);

  static Future<Map<String, double>> searchLocation(String address) async {
    if (Platform.isIOS) {
      return searchLocationForIOS(address);
    } else if (Platform.isAndroid) {
      return searchLocationForAndroid(address);
    }
    throw Exception('Unsupported platform');
  }

  static Future<Map<String, double>> searchLocationForIOS(String address) async {
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

  static Future<Map<String, double>> searchLocationForAndroid(String address) async {
    try {
      debugPrint('🔍 [LocationSearchService] Searching Android location for: $address');
      final List<Location> locations = await locationFromAddress(address);

      if (locations.isEmpty) {
        throw Exception('No location found for address');
      }

      final location = locations.first;
      debugPrint('✅ [LocationSearchService] Found Android location: ${location.latitude}, ${location.longitude}');

      return {
        'latitude': location.latitude,
        'longitude': location.longitude,
      };
    } catch (e) {
      debugPrint('❌ [LocationSearchService] Android location search error: $e');
      throw Exception('Failed to find location: $e');
    }
  }
}
