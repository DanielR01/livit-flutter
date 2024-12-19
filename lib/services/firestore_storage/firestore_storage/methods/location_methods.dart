import 'package:livit/cloud_models/location/location.dart';
import 'package:livit/services/firestore_storage/firestore_storage/collections.dart';

class LocationMethods {
  static final LocationMethods _shared = LocationMethods._sharedInstance();
  LocationMethods._sharedInstance();
  factory LocationMethods() => _shared;

  final Collections _collections = Collections();

  Future<void> createLocation(String userId, Location location) async {
    final locationRef = _collections.locationsCollection(userId);
    await locationRef.add(location);
  }

  Future<List<Location>> getUserLocations(String userId) async {
    final locations = await _collections.locationsCollection(userId).get();
    return locations.docs.map((doc) => doc.data()).toList();
  }

  Future<void> updateLocation(String userId, Location location) async {
    final locationRef = _collections.locationsCollection(userId).doc(location.id);
    await locationRef.update(location.toMap());
  }
}
