import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livit/cloud_models/user/private_data.dart';
import 'package:livit/services/firestore_storage/bloc/firestore_storage/collections.dart';
import 'package:livit/services/firestore_storage/bloc/firestore_storage/firestore_storage_exceptions.dart';

class PrivateDataMethods {
  static final PrivateDataMethods _shared = PrivateDataMethods._sharedInstance();
  PrivateDataMethods._sharedInstance();
  factory PrivateDataMethods() => _shared;

  final Collections _collections = Collections();

  Future<UserPrivateData> getPrivateData({required String userId}) async {
    try {
      final doc = await _collections.usersCollection.doc(userId).collection('private').doc('privateData').get();
      if (doc.exists) {
        return UserPrivateData.fromFirestore(doc);
      } else {
        throw PrivateDataNotFoundException();
      }
    } catch (e) {
      if (e is PrivateDataNotFoundException) {
        rethrow;
      }
      throw CouldNotGetPrivateDataException();
    }
  }

  Future<void> updatePrivateData({
    required String userId,
    required UserPrivateData privateData,
    required Transaction transaction,
  }) async {
    final privateDataRef = _collections.usersCollection.doc(userId).collection('private').doc('privateData');
    transaction.update(privateDataRef, privateData.toMap());
  }
}
