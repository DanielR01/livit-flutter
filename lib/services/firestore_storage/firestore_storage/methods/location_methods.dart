import 'package:livit/cloud_models/location/location.dart';
import 'package:livit/services/firestore_storage/firestore_storage/collections.dart';
import 'package:livit/services/firestore_storage/firestore_storage/exceptions/locations_exceptions.dart';

class LocationMethods {
  static final LocationMethods _shared = LocationMethods._sharedInstance();
  LocationMethods._sharedInstance();
  factory LocationMethods() => _shared;

  final Collections _collections = Collections();

  Future<void> createLocation(String userId, Location location) async {
    try {
      final locationRef = _collections.locationsCollection(userId);
      await locationRef.add(location);
    } catch (e) {
      throw CouldNotCreateLocationException(message: e.toString());
    }
  }

  Future<List<Location>> getUserLocations(String userId) async {
    try {
      final locations = await _collections.locationsCollection(userId).get();
      return locations.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw CouldNotGetUserLocationsException(message: e.toString());
    }
  }

  Future<void> updateLocation(String userId, Location location) async {
    try {
      final locationRef = _collections.locationsCollection(userId).doc(location.id);
      await locationRef.update(location.toMap());
    } catch (e) {
      throw CouldNotUpdateLocationException(message: e.toString());
    }
  }

  Future<Location> getLocation(String userId, String locationId) async {
    try {
      final locationRef = _collections.locationsCollection(userId).doc(locationId);
      final location = await locationRef.get();
      if (location.exists) {
        return location.data()!;
      } else {
        throw CouldNotGetLocationException(message: 'Location not found');
      }
    } catch (e) {
      throw CouldNotGetLocationException(message: e.toString());
    }
  }

  Future<void> deleteLocation(String userId, Location location) async {
    try {
      final locationRef = _collections.locationsCollection(userId).doc(location.id);
      await locationRef.delete();
    } catch (e) {
      throw CouldNotDeleteLocationException(message: e.toString());
    }
  }
}
