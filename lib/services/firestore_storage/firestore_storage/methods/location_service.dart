import 'package:flutter/material.dart';
import 'package:livit/models/location/location.dart';
import 'package:livit/services/firestore_storage/firestore_storage/collections.dart';
import 'package:livit/services/firestore_storage/firestore_storage/exceptions/locations_exceptions.dart';

class LocationService {
  static final LocationService _shared = LocationService._sharedInstance();
  LocationService._sharedInstance();
  factory LocationService() => _shared;

  final Collections _collections = Collections();

  Future<List<LivitLocation>> getUserLocations(String userId) async {
    try {
      debugPrint('📥 [LocationMethods] Getting user locations for $userId');
      final locations = await _collections.locationsCollection.where('userId', isEqualTo: userId).get();
      debugPrint('📥 [LocationMethods] Found ${locations.docs.length} locations for $userId');
      return locations.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('❌ [LocationMethods] Could not get user locations for $userId: $e');
      throw CouldNotGetUserLocationsException(details: e.toString());
    }
  }

  Future<void> updateLocation(LivitLocation location) async {
    try {
      debugPrint('📥 [LocationMethods] Updating location ${location.id}');
      final locationRef = _collections.locationsCollection.doc(location.id);
      await locationRef.update(location.toMap());
    } catch (e) {
      debugPrint('❌ [LocationMethods] Could not update location ${location.id}: $e');
      throw CouldNotUpdateLocationException(details: e.toString());
    }
  }

  Future<LivitLocation> getLocation(String locationId) async {
    try {
      debugPrint('📥 [LocationMethods] Getting location $locationId');
      final locationRef = _collections.locationsCollection.doc(locationId);
      final location = await locationRef.get();
      if (location.exists) {
        debugPrint('📥 [LocationMethods] Location $locationId found');
        return location.data()!;
      } else {
        debugPrint('❌ [LocationMethods] Location $locationId not found');
        throw CouldNotGetLocationException(details: 'Location not found');
      }
    } catch (e) {
      debugPrint('❌ [LocationMethods] Could not get location $locationId: $e');
      throw CouldNotGetLocationException(details: e.toString());
    }
  }

  Future<void> deleteLocation(LivitLocation location) async {
    try {
      debugPrint('📥 [LocationMethods] Deleting location ${location.id}');
      final locationRef = _collections.locationsCollection.doc(location.id);
      await locationRef.delete();
      debugPrint('🗑️ [LocationMethods] Location ${location.id} deleted');
    } catch (e) {
      debugPrint('❌ [LocationMethods] Could not delete location ${location.id}: $e');
      throw CouldNotDeleteLocationException(details: e.toString());
    }
  }
}
