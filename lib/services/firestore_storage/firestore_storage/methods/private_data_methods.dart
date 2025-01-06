import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livit/cloud_models/user/private_data.dart';
import 'package:livit/services/firestore_storage/firestore_storage/collections.dart';
import 'package:livit/services/firestore_storage/firestore_storage/exceptions/firestore_exceptions.dart';

class PrivateDataMethods {
  static final PrivateDataMethods _shared = PrivateDataMethods._sharedInstance();
  PrivateDataMethods._sharedInstance();
  factory PrivateDataMethods() => _shared;

  final Collections _collections = Collections();

  Future<UserPrivateData> getPrivateData({required String userId}) async {
    try {
      final doc = await _collections.privateDataDocument(userId).get();
      if (doc.exists) {
        return doc.data()!;
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

  Future<void> updatePrivateDataWithTransaction({
    required String userId,
    required UserPrivateData privateData,
    required Transaction transaction,
  }) async {
    try {
      final privateDataRef = _collections.privateDataDocument(userId);
      transaction.update(privateDataRef, privateData.toMap());
    } catch (e) {
      throw CouldNotUpdatePrivateDataException();
    }
  }

  Future<void> updatePrivateData({
    required String userId,
    required UserPrivateData privateData,
  }) async {
    try {
      final privateDataRef = FirebaseFirestore.instance.collection('users').doc(userId).collection('private').doc('privateData');
      await privateDataRef.update(privateData.toMap());
    } catch (e) {
      throw CouldNotUpdatePrivateDataException(details: e.toString());
    }
  }

  Future<void> updatePromoterPrivateData({
    required String userId,
    required PromoterPrivateData privateData,
  }) async {
    try {
      final privateDataRef = _collections.privateDataDocument(userId);
      await privateDataRef.update(privateData.toMap());
    } catch (e) {
      throw CouldNotUpdatePrivateDataException(details: e.toString());
    }
  }
}
