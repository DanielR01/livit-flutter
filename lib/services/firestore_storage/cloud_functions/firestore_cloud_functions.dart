import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:livit/cloud_models/user/cloud_user.dart';
import 'package:livit/cloud_models/user/private_data.dart';
import 'package:livit/services/firestore_storage/cloud_functions/cloud_functions_exceptions.dart';
import 'package:livit/services/firestore_storage/firestore_storage/exceptions/firestore_exceptions.dart';

class FirestoreCloudFunctions {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<Timestamp> createUserAndUsername({
    required CloudUser user,
    required UserPrivateData privateData,
  }) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable('createUserAndUsername');
      final name = user.name;
      final userType = user.userType.name;
      final username = user.username;
      final userId = user.id;
      final phoneNumber = privateData.phoneNumber;
      final email = privateData.email;
      final response = await callable.call({
        'userId': userId,
        'username': username,
        'userType': userType,
        'name': name,
        'phoneNumber': phoneNumber,
        'email': email,
      });
      if (response.data['status'] != "success" || response.data['createdAt'] == null) {
        throw GenericCloudFunctionException();
      }
      final createdAt = Timestamp.fromDate(DateTime.parse(response.data['createdAt']));
      return createdAt;
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'already-exists') {
        if (e.message == 'UsernameAlreadyTakenError') {
          throw UsernameAlreadyTakenException();
        } else if (e.message == 'UserAlreadyExistsError') {
          throw UserAlreadyExistsException();
        }
      }
      throw GenericCloudFunctionException();
    } catch (e) {
      throw GenericCloudFunctionException();
    }
  }
}
