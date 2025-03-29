import 'package:cloud_functions/cloud_functions.dart';
import 'package:livit/models/location/location.dart';
import 'package:livit/services/cloud_functions/cloud_functions_exceptions.dart';
import 'package:livit/utilities/debug/livit_debugger.dart';
import 'package:livit/models/event/event.dart';

class FirestoreCloudFunctions {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final LivitDebugger _debugger = const LivitDebugger('firestore_cloud_functions', isDebugEnabled: true);

  Future<void> createUserAndUsername({
    required String userId,
    required String username,
    required String userType,
    required String name,
    required String phoneNumber,
    required String email,
  }) async {
    try {
      _debugger.debPrint('Creating user $username', DebugMessageType.creating);
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
        _debugger.debPrint('Could not create user $username: ${response.data['error']}', DebugMessageType.error);
        throw GenericCloudFunctionException(details: response.data['error']);
      }
      _debugger.debPrint('User $username created', DebugMessageType.done);
      return;
    } on FirebaseFunctionsException catch (e) {
      _debugger.debPrint('Could not create user: $e', DebugMessageType.error);
      if (e.code == 'already-exists') {
        if (e.message == 'UsernameAlreadyTakenError') {
          throw UsernameAlreadyTakenException();
        } else if (e.message == 'UserAlreadyExistsError') {
          throw UserAlreadyExistsException();
        }
      }
      throw GenericCloudFunctionException(details: e.toString());
    } catch (e) {
      _debugger.debPrint('Could not create user: $e', DebugMessageType.error);
      throw GenericCloudFunctionException(details: e.toString());
    }
  }

  Future<String> createLocation({
    required LivitLocation location,
  }) async {
    try {
      _debugger.debPrint('Creating location ${location.name}', DebugMessageType.creating);
      final HttpsCallable callable = _functions.httpsCallable('createLocation');
      final response = await callable.call({
        'name': location.name,
        'description': location.description,
        'address': location.address,
        'city': location.city,
        'state': location.state,
      });
      if (response.data['status'] != "success") {
        _debugger.debPrint('Could not create location ${location.name}: ${response.data['error']}', DebugMessageType.error);
        throw GenericCloudFunctionException(details: response.data['error']);
      } else if (response.data['locationId'] == null) {
        _debugger.debPrint('Location ID is null after location creation', DebugMessageType.error);
        throw GenericCloudFunctionException(details: 'Location ID is null after location creation');
      }
      _debugger.debPrint('Response: ${response.data}', DebugMessageType.response);
      _debugger.debPrint('Location ${location.name} created', DebugMessageType.done);
      return response.data['locationId'];
    } catch (e) {
      _debugger.debPrint('Could not create location: $e', DebugMessageType.error);
      throw GenericCloudFunctionException(details: e.toString());
    }
  }

  Future<void> updatePromoterUserNoLocations({
    required String userId,
  }) async {
    _debugger.debPrint('Updating promoter user no locations for $userId', DebugMessageType.updating);
    final HttpsCallable callable = _functions.httpsCallable('updatePromoterUserNoLocations');
    final response = await callable.call({'userId': userId});
    if (response.data['status'] != "success") {
      _debugger.debPrint('Could not update promoter user no locations: ${response.data['error']}', DebugMessageType.error);
      throw GenericCloudFunctionException(details: response.data['error']);
    }
    _debugger.debPrint('✅ [FirestoreCloudFunctions] Promoter user no locations updated', DebugMessageType.done);
  }

  Future<String> createScannerAccount({
    required String promoterId,
    required List<String> locationIds,
    required List<String> eventIds,
    required String name,
  }) async {
    try {
      _debugger.debPrint('Creating scanner account for promoter $promoterId', DebugMessageType.creating);

      final HttpsCallable callable = _functions.httpsCallable('createScanner');

      final response = await callable.call({
        'promoterId': promoterId,
        'locationIds': locationIds,
        'eventIds': eventIds,
        'name': name,
      });

      if (response.data['success'] != true) {
        _debugger.debPrint('Could not create scanner account: ${response.data['error']}', DebugMessageType.error);
        throw GenericCloudFunctionException(details: response.data['error']);
      }

      final String scannerId = response.data['userId'] as String;
      _debugger.debPrint('Scanner account created with ID: $scannerId', DebugMessageType.done);
      return scannerId;
    } catch (e) {
      _debugger.debPrint('Could not create scanner account: $e', DebugMessageType.error);
      throw GenericCloudFunctionException(details: e.toString());
    }
  }

  Future<void> deleteScannerAccount({
    required String scannerId,
  }) async {
    try {
      _debugger.debPrint('Deleting scanner account for $scannerId', DebugMessageType.deleting);
      final HttpsCallable callable = _functions.httpsCallable('deleteScanner');
      final response = await callable.call({'scannerId': scannerId});
      if (response.data['success'] != true) {
        _debugger.debPrint('Could not delete scanner account: ${response.data['error']}', DebugMessageType.error);
        throw GenericCloudFunctionException(details: response.data['error']);
      }
      _debugger.debPrint('Scanner account deleted', DebugMessageType.done);
    } catch (e) {
      _debugger.debPrint('Could not delete scanner account: $e', DebugMessageType.error);
      throw GenericCloudFunctionException(details: e.toString());
    }
  }

  Future<String> createEvent({
    required LivitEvent event,
  }) async {
    try {
      _debugger.debPrint('Creating event: ${event.name}', DebugMessageType.creating);
      _debugger.debPrint('Event data structure: ${event.toString()}', DebugMessageType.info);

      final HttpsCallable callable = _functions.httpsCallable('createEvent');

      // Use the event's toMap method which now properly serializes all data
      final eventData = event.toMap();

      _debugger.debPrint('Event serialized for cloud function', DebugMessageType.info);
      _debugger.debPrint('Data fields: ${eventData.keys.join(", ")}', DebugMessageType.info);
      _debugger.debPrint('Event dates count: ${eventData['dates']?.length}', DebugMessageType.info);
      _debugger.debPrint('Event tickets count: ${eventData['tickets']?.length}', DebugMessageType.info);
      _debugger.debPrint('Event locations count: ${eventData['locations']?.length}', DebugMessageType.info);

      final response = await callable.call(eventData);

      if (response.data['status'] != "success") {
        _debugger.debPrint('Could not create event ${event.name}: ${response.data['error']}', DebugMessageType.error);
        throw GenericCloudFunctionException(details: response.data['error']);
      }

      _debugger.debPrint('Event ${event.name} created with ID: ${response.data['eventId']}', DebugMessageType.done);
      return response.data['eventId'];
    } on FirebaseFunctionsException catch (e) {
      _debugger.debPrint('Firebase function error creating event: ${e.message}', DebugMessageType.error);
      _debugger.debPrint('Error code: ${e.code}', DebugMessageType.error);
      _debugger.debPrint('Error details: ${e.details}', DebugMessageType.error);
      throw GenericCloudFunctionException(details: e.toString());
    } catch (e) {
      _debugger.debPrint('Unexpected error creating event: $e', DebugMessageType.error);
      _debugger.debPrint('Error stack trace: ${StackTrace.current}', DebugMessageType.error);
      throw GenericCloudFunctionException(details: e.toString());
    }
  }
}
