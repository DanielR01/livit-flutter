import 'package:cloud_functions/cloud_functions.dart';
import 'package:livit/cloud_models/cloud_user.dart';
import 'package:livit/services/cloud/cloud_functions/cloud_functions_exceptions.dart';

class FirestoreCloudFunctions {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<void> createUserAndUsername({
    required CloudUser user,
  }) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable('createUserAndUsername');
      final name = user.name;
      final userType = user.userType;
      final username = user.username;
      final userId = user.id;
      final response = await callable.call({
        'userId': userId,
        'username': username,
        'userType': userType,
        'name': name,
      });
      if (response.data == null) {
        throw GenericCloudFunctionException();
      } else if (response.data != "UserAndUsernameCreatedSuccessfully") {
        throw GenericCloudFunctionException();
      }
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'already-exists') {
        if (e.message == 'UsernameAlreadyTakenError') {
          throw UsernameAlreadyTakenException();
        } else if (e.message == 'UserAlreadyExistsError') {
          throw UserAlreadyExistsException();
        }
      }
    } catch (e) {
      throw GenericCloudFunctionException();
    }
  }
}
