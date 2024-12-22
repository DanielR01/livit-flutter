import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livit/cloud_models/user/cloud_user.dart';
import 'package:livit/services/firestore_storage/firestore_storage/collections.dart';
import 'package:livit/services/firestore_storage/firestore_storage/exceptions/firestore_exceptions.dart';

class UserMethods {
  static final UserMethods _shared = UserMethods._sharedInstance();
  UserMethods._sharedInstance();
  factory UserMethods() => _shared;

  final Collections _collections = Collections();

  Future<CloudUser> getUser({required String userId}) async {
    try {
      final doc = await _collections.usersCollection.doc(userId).get();
      if (doc.exists) {
        try {
          return doc.data()!;
        } catch (e) {
          throw CouldNotGetUserException();
        }
      } else {
        throw UserNotFoundException();
      }
    } on FirebaseException {
      throw CouldNotGetUserException();
    } catch (e) {
      if (e is UserNotFoundException) {
        rethrow;
      }
      throw CouldNotGetUserException();
    }
  }

  Future<void> updateUser({required CloudUser user}) async {
    try {
      await _collections.usersCollection.doc(user.id).update(user.toMap());
    } catch (e) {
      throw CouldNotUpdateUserException(message: e.toString());
    }
  }
}
