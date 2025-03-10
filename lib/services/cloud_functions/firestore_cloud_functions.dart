import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:livit/models/location/location.dart';
import 'package:livit/services/cloud_functions/cloud_functions_exceptions.dart';

class FirestoreCloudFunctions {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<void> createUserAndUsername({
    required String userId,
    required String username,
    required String userType,
    required String name,
    required String phoneNumber,
    required String email,
  }) async {
    try {
      debugPrint('📥 [FirestoreCloudFunctions] Creating user $username');
      final HttpsCallable callable = _functions.httpsCallable('createUserAndUsername');
      final response = await callable.call({
        'userId': userId,
        'username': username,
        'userType': userType,
        'name': name,
        'phoneNumber': phoneNumber,
        'email': email,
      });
      if (response.data['success'] != true) {
        debugPrint('❌ [FirestoreCloudFunctions] Could not create user $username: ${response.data['error']}');
        throw GenericCloudFunctionException(details: response.data['error']);
      }
      debugPrint('✅ [FirestoreCloudFunctions] User $username created');
      return;
    } on FirebaseFunctionsException catch (e) {
      debugPrint('❌ [FirestoreCloudFunctions] Could not create user: $e');
      if (e.code == 'already-exists') {
        if (e.message == 'UsernameAlreadyTakenError') {
          throw UsernameAlreadyTakenException();
        } else if (e.message == 'UserAlreadyExistsError') {
          throw UserAlreadyExistsException();
        }
      }
      throw GenericCloudFunctionException(details: e.toString());
    } catch (e) {
      debugPrint('❌ [FirestoreCloudFunctions] Could not create user: $e');
      throw GenericCloudFunctionException(details: e.toString());
    }
  }

  Future<String> createLocation({
    required LivitLocation location,
  }) async {
    try {
      debugPrint('📥 [FirestoreCloudFunctions] Creating location ${location.name}');
      final HttpsCallable callable = _functions.httpsCallable('createLocation');
      final response = await callable.call({
        'name': location.name,
        'description': location.description,
        'address': location.address,
        'city': location.city,
        'state': location.state,
      });
      if (response.data['status'] != "success") {
        debugPrint('❌ [FirestoreCloudFunctions] Could not create location ${location.name}: ${response.data['error']}');
        throw GenericCloudFunctionException(details: response.data['error']);
      } else if (response.data['locationId'] == null) {
        debugPrint('❌ [FirestoreCloudFunctions] Location ID is null after location creation');
        throw GenericCloudFunctionException(details: 'Location ID is null after location creation');
      }
      debugPrint('📬 [FirestoreCloudFunctions] Response: ${response.data}');
      debugPrint('✅ [FirestoreCloudFunctions] Location ${location.name} created');
      return response.data['locationId'];
    } catch (e) {
      debugPrint('❌ [FirestoreCloudFunctions] Could not create location: $e');
      throw GenericCloudFunctionException(details: e.toString());
    }
  }

  Future<void> updatePromoterUserNoLocations({
    required String userId,
  }) async {
    debugPrint('📥 [FirestoreCloudFunctions] Updating promoter user no locations for $userId');
    final HttpsCallable callable = _functions.httpsCallable('updatePromoterUserNoLocations');
    final response = await callable.call({'userId': userId});
    if (response.data['status'] != "success") {
      debugPrint('❌ [FirestoreCloudFunctions] Could not update promoter user no locations: ${response.data['error']}');
      throw GenericCloudFunctionException(details: response.data['error']);
    }
    debugPrint('✅ [FirestoreCloudFunctions] Promoter user no locations updated');
  }

  Future<String> createScannerAccount({
    required String promoterId,
    required List<String> locationIds,
    required List<String> eventIds,
    required String name,
  }) async {
    try {
      debugPrint('📥 [FirestoreCloudFunctions] Creating scanner account for promoter $promoterId');

      final HttpsCallable callable = _functions.httpsCallable('createScanner');

      final response = await callable.call({
        'promoterId': promoterId,
        'locationIds': locationIds,
        'eventIds': eventIds,
        'name': name,
      });

      if (response.data['success'] != true) {
        debugPrint('❌ [FirestoreCloudFunctions] Could not create scanner account: ${response.data['error']}');
        throw GenericCloudFunctionException(details: response.data['error']);
      }

      final String scannerId = response.data['userId'] as String;
      debugPrint('✅ [FirestoreCloudFunctions] Scanner account created with ID: $scannerId');
      return scannerId;
    } catch (e) {
      debugPrint('❌ [FirestoreCloudFunctions] Could not create scanner account: $e');
      throw GenericCloudFunctionException(details: e.toString());
    }
  }

  Future<void> deleteScannerAccount({
    required String scannerId,
  }) async {
    try {
      debugPrint('📥 [FirestoreCloudFunctions] Deleting scanner account for $scannerId');
      final HttpsCallable callable = _functions.httpsCallable('deleteScanner');
      final response = await callable.call({'scannerId': scannerId});
      if (response.data['success'] != true) {
        debugPrint('❌ [FirestoreCloudFunctions] Could not delete scanner account: ${response.data['error']}');
        throw GenericCloudFunctionException(details: response.data['error']);
      }
      debugPrint('✅ [FirestoreCloudFunctions] Scanner account deleted');
    } catch (e) {
      debugPrint('❌ [FirestoreCloudFunctions] Could not delete scanner account: $e');
      throw GenericCloudFunctionException(details: e.toString());
    }
  }
}
