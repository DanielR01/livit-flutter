import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livit/cloud_models/user/cloud_user.dart';
import 'package:livit/cloud_models/user/private_data.dart';
import 'package:livit/services/firestore_storage/bloc/firestore_storage/methods/private_data_methods.dart';
import 'package:livit/services/firestore_storage/bloc/firestore_storage/methods/user_methods.dart';
import 'package:livit/services/firestore_storage/bloc/firestore_storage/methods/event_methods.dart';
import 'package:livit/services/firestore_storage/bloc/firestore_storage/ticket_methods.dart';
import 'package:livit/services/firestore_storage/bloc/firestore_storage/firestore_storage_exceptions.dart';

class FirestoreStorage {
  static final FirestoreStorage _shared = FirestoreStorage._sharedInstance();
  FirestoreStorage._sharedInstance();
  factory FirestoreStorage() => _shared;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserMethods userMethods = UserMethods();
  final EventMethods eventMethods = EventMethods();
  final TicketMethods ticketMethods = TicketMethods();
  final PrivateDataMethods privateDataMethods = PrivateDataMethods();

  Future<void> updateUserAndPrivateDataInTransaction({
    required CloudUser user,
    required UserPrivateData privateData,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(user.id);
        final privateDataRef = userRef.collection('private').doc('privateData');

        transaction.update(userRef, user.toMap());
        transaction.update(privateDataRef, privateData.toMap());
      });
    } catch (e) {
      throw CouldNotUpdateUserException();
    }
  }
}
