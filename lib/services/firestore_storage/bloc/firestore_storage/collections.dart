import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livit/cloud_models/user/cloud_user.dart';
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
      fromFirestore: (snap, _) => CloudUser.fromDocument(snap),
      toFirestore: (user, _) => user.toMap(),
    );

final CollectionReference<LivitTicket> ticketsCollection = FirebaseFirestore.instance.collection('tickets').withConverter<LivitTicket>(
      fromFirestore: (snap, _) => LivitTicket.fromDocument(snap),
      toFirestore: (ticket, _) => ticket.toMap(),
    );

  final CollectionReference<Map<String, dynamic>> usernamesCollection = FirebaseFirestore.instance.collection('usernames');
}
