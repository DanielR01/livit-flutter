import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:livit/models/location/location.dart';
import 'package:livit/services/firestore_storage/cloud_functions/cloud_functions_exceptions.dart';

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
      if (response.data['status'] != "success") {
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

  // Future<Map<String, List<dynamic>>> getLocationMediaUploadUrls({
  //   required String locationId,
  //   required List<int> fileSizes,
  //   required List<String> fileTypes,
  //   required List<String> names,
  // }) async {
  //   try {
  //     debugPrint('📥 [FirestoreCloudFunctions] Getting location media upload URL for $locationId');
  //     final HttpsCallable callable = _functions.httpsCallable('getLocationMediaUploadUrl');
  //     final response = await callable.call({
  //       'locationId': locationId,
  //       'fileSizes': fileSizes,
  //       'fileTypes': fileTypes,
  //       'names': names,
  //     });
  //     debugPrint('📥 [FirestoreCloudFunctions] Got a response');
  //     debugPrint('📥 [FirestoreCloudFunctions] Response: ${response.data}');
  //     final Map<String, dynamic> responseData = Map<String, dynamic>.from(response.data);
  //     final List<String> signedUrls = List<String>.from(responseData['signedUrls']);
  //     final List<Map<String, dynamic>> timestampsAsSecondsAndNanos =
  //         (responseData['timestamps'] as List).map((item) => Map<String, dynamic>.from(item as Map)).toList();
  //     final List<Timestamp> timestamps =
  //         timestampsAsSecondsAndNanos.map((e) => Timestamp(e['_seconds'] as int, e['_nanoseconds'] as int)).toList();

  //     if (signedUrls.isEmpty || timestamps.isEmpty) {
  //       debugPrint('❌ [FirestoreCloudFunctions] Signed URL or timestamps is null after getting location media upload URL');
  //       throw GenericCloudFunctionException(details: 'Signed URL or timestamps is null after getting location media upload URL');
  //     }

  //     debugPrint('✅ [FirestoreCloudFunctions] Signed URLs for location media upload for $locationId received');
  //     debugPrint('📥 [FirestoreCloudFunctions] Timestamps: $timestamps');
  //     return {
  //       'signedUrls': signedUrls,
  //       'timestamps': timestamps,
  //     };
  //   } on FirebaseFunctionsException catch (e) {
  //     if (e.message == 'file-size-limit') {
  //       debugPrint('❌ [FirestoreCloudFunctions] File size exceeds limit, throwing LocationMediaFileSizeExceedsLimitException');
  //       throw LocationMediaFileSizeExceedsLimitException();
  //     } else if (e.message == 'files-limit') {
  //       debugPrint('❌ [FirestoreCloudFunctions] Location exceeds files limit, throwing LocationMediaExceedsMaxFilesLimitException');
  //       throw LocationMediaExceedsMaxFilesLimitException();
  //     } else if (e.message == 'user-does-not-have-permission') {
  //       debugPrint(
  //           '❌ [FirestoreCloudFunctions] User does not have permission to upload media to location, throwing UserDoesNotHavePermissionToUploadMediaToLocationException');
  //       throw UserDoesNotHavePermissionToUploadMediaToLocationException();
  //     } else if (e.message == 'location-files-not-match') {
  //       debugPrint('❌ [FirestoreCloudFunctions] Location files not match, throwing LocationFilesNotMatchException');
  //       throw LocationFilesNotMatchException();
  //     } else if (e.message == 'missing-params') {
  //       debugPrint('❌ [FirestoreCloudFunctions] Missing parameters, throwing MissingParametersException');
  //       throw MissingParametersException();
  //     } else if (e.message == 'location-not-found') {
  //       debugPrint('❌ [FirestoreCloudFunctions] Location not found, throwing LocationNotFoundException');
  //       throw LocationNotFoundException();
  //     }
  //     debugPrint('❌ [FirestoreCloudFunctions] Could not get location media upload URL, unknown error: ${e.toString()}');
  //     throw GenericCloudFunctionException(details: e.toString());
  //   } on CloudFunctionException catch (e) {
  //     debugPrint('❌ [FirestoreCloudFunctions] Could not get location media upload URL, cloud function exception: $e');
  //     rethrow;
  //   } catch (e) {
  //     debugPrint('❌ [FirestoreCloudFunctions] Could not get location media upload URL, unknown error: $e');
  //     throw GenericCloudFunctionException(details: e.toString());
  //   }
  // }

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
}
