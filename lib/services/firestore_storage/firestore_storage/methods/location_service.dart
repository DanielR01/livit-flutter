import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<List<LivitLocation>> getLocationsByIds(List<String> locationIds) async {
    try {
      debugPrint('📥 [LocationMethods] Getting locations by ids $locationIds');

      if (locationIds.isEmpty) {
        debugPrint('📥 [LocationMethods] Location ids list is empty, returning empty list');
        return [];
      }

      // For small lists, use whereIn query (most efficient for small batches)
      if (locationIds.length <= 10) {
        final locations = await _collections.locationsCollection.where(FieldPath.documentId, whereIn: locationIds).get();

        debugPrint('📥 [LocationMethods] Found ${locations.docs.length} locations by ids $locationIds');
        return locations.docs.map((doc) => doc.data()).toList();
      }
      // For larger lists, use direct document fetches in batches
      else {
        final List<LivitLocation> locations = [];

        // Process in batches of 20 for parallel fetching
        const batchSize = 20;
        for (int i = 0; i < locationIds.length; i += batchSize) {
          final end = (i + batchSize < locationIds.length) ? i + batchSize : locationIds.length;
          final batch = locationIds.sublist(i, end);

          final batchFutures = batch.map((id) => _collections.locationsCollection.doc(id).get());
          final batchSnapshots = await Future.wait(batchFutures);

          locations.addAll(batchSnapshots.where((snapshot) => snapshot.exists).map((snapshot) => snapshot.data()!));
        }

        debugPrint('📥 [LocationMethods] Found ${locations.length} locations by ids $locationIds');
        return locations;
      }
    } catch (e) {
      debugPrint('❌ [LocationMethods] Could not get locations by ids $locationIds: $e');
      throw CouldNotGetLocationsByIdsException(details: e.toString());
    }
  }
}
