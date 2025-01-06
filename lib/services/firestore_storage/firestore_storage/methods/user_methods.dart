import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:livit/cloud_models/user/cloud_user.dart';
import 'package:livit/services/firestore_storage/firestore_storage/collections.dart';
import 'package:livit/services/firestore_storage/firestore_storage/exceptions/firestore_exceptions.dart';

class UserMethods {
  static final UserMethods _shared = UserMethods._sharedInstance();
  UserMethods._sharedInstance();
  factory UserMethods() => _shared;

  final Collections _collections = Collections();

  Future<CloudUser> getUser({required String userId}) async {
    final doc = await _collections.usersCollection.doc(userId).get();
    if (doc.exists) {
      try {
        return doc.data()!;
      } catch (e) {
        throw UserInformationCorruptedException(details: e.toString());
      }
    } else {
      throw UserNotFoundException();
    }
  }

  Future<void> updateUser({required CloudUser user}) async {
    try {
      debugPrint('🔄 [UserMethods] Updating user ${user.id}');
      await _collections.usersCollection.doc(user.id).update(user.toMap());
      debugPrint('🔄 [UserMethods] User updated');
    } catch (e) {
      debugPrint('❌ [UserMethods] Could not update user: $e');
      throw CouldNotUpdateUserException(details: e.toString());
    }
  }
}
