import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livit/cloud_models/user/cloud_user.dart';
import 'package:livit/cloud_models/user/private_data.dart';
import 'package:livit/services/firestore_storage/firestore_storage/collections.dart';
import 'package:livit/services/firestore_storage/firestore_storage/methods/location_methods.dart';
import 'package:livit/services/firestore_storage/firestore_storage/methods/private_data_methods.dart';
import 'package:livit/services/firestore_storage/firestore_storage/methods/user_methods.dart';
import 'package:livit/services/firestore_storage/firestore_storage/methods/event_methods.dart';
import 'package:livit/services/firestore_storage/firestore_storage/methods/username_methods.dart';
import 'package:livit/services/firestore_storage/firestore_storage/ticket_methods.dart';
import 'package:livit/services/firestore_storage/firestore_storage/exceptions/firestore_exceptions.dart';

class FirestoreStorage {
  static final FirestoreStorage _shared = FirestoreStorage._sharedInstance();
  FirestoreStorage._sharedInstance();
  factory FirestoreStorage() => _shared;

  final UserMethods userMethods = UserMethods();
  final UsernameMethods usernameMethods = UsernameMethods();
  final EventMethods eventMethods = EventMethods();
  final TicketMethods ticketMethods = TicketMethods();
  final PrivateDataMethods privateDataMethods = PrivateDataMethods();
  final LocationMethods locationMethods = LocationMethods();
}
