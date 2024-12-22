import 'package:livit/services/firestore_storage/firestore_storage/collections.dart';
import 'package:livit/services/firestore_storage/firestore_storage/exceptions/firestore_exceptions.dart';

class UsernameMethods {
  static final UsernameMethods _shared = UsernameMethods._sharedInstance();
  UsernameMethods._sharedInstance();
  factory UsernameMethods() => _shared;

  final Collections _collections = Collections();

  Future<bool> isUsernameTaken(String username) async {
    try {
      final doc = await _collections.usernamesCollection.doc(username).get();
      return doc.exists;
    } catch (_) {
      throw CouldNotCheckUsernameException();
    }
  }
}
