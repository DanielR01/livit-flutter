import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livit/cloud_models/location/location.dart';
import 'package:livit/cloud_models/location/private_data/location_private_data.dart';
import 'package:livit/cloud_models/user/cloud_user.dart';
import 'package:livit/cloud_models/user/private_data.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/services/firestore_storage/firestore_storage/exceptions/firestore_exceptions.dart';
import 'package:livit/services/firestore_storage/livit_event.dart';
import 'package:livit/services/firestore_storage/livit_ticket.dart';

class Collections {
  static final Collections _shared = Collections._sharedInstance();
  Collections._sharedInstance();
  factory Collections() => _shared;

  final CollectionReference<LivitEvent> eventsCollection = FirebaseFirestore.instance.collection('events').withConverter<LivitEvent>(
        fromFirestore: (snap, _) => LivitEvent.fromDocument(snap),
        toFirestore: (event, _) => event.toMap(),
      );

  final CollectionReference<CloudUser> usersCollection = FirebaseFirestore.instance.collection('users').withConverter<CloudUser>(
        fromFirestore: (snap, _) {
          final data = snap.data() as Map<String, dynamic>;
          if (data['userType'] == UserType.customer.name) {
            return CloudCustomer.fromDocument(snap);
          } else if (data['userType'] == UserType.promoter.name) {
            return CloudPromoter.fromDocument(snap);
          }
          throw UserInformationCorruptedException(details: 'User type not found');
        },
        toFirestore: (user, _) => user.toMap(),
      );

  final CollectionReference<LivitTicket> ticketsCollection = FirebaseFirestore.instance.collection('tickets').withConverter<LivitTicket>(
        fromFirestore: (snap, _) => LivitTicket.fromDocument(snap),
        toFirestore: (ticket, _) => ticket.toMap(),
      );

  final CollectionReference<Map<String, dynamic>> usernamesCollection = FirebaseFirestore.instance.collection('usernames');

  final CollectionReference<LivitLocation> locationsCollection =
      FirebaseFirestore.instance.collection('locations').withConverter<LivitLocation>(
            fromFirestore: (snap, _) => LivitLocation.fromDocument(snap),
            toFirestore: (location, _) => location.toMap(),
          );

  DocumentReference<LocationPrivateData> locationPrivateDataDocument(String locationId) =>
      locationsCollection.doc(locationId).collection('private').doc('privateData').withConverter<LocationPrivateData>(
            fromFirestore: (snap, _) => LocationPrivateData.fromDocument(snap),
            toFirestore: (privateData, _) => privateData.toMap(),
          );

  DocumentReference<UserPrivateData> privateDataDocument(String userId) =>
      usersCollection.doc(userId).collection('private').doc('privateData').withConverter<UserPrivateData>(
            fromFirestore: (snap, _) => UserPrivateData.fromDocument(snap),
            toFirestore: (privateData, _) => privateData.toMap(),
          );
}
