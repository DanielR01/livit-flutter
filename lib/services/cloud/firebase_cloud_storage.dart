import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livit/cloud_models/user/cloud_user.dart';
import 'package:livit/cloud_models/user/private_data.dart';
import 'package:livit/services/cloud/livit_event.dart';
import 'package:livit/services/cloud/livit_ticket.dart';
import 'package:livit/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  static final FirebaseCloudStorage _shared = FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // **User Methods**

  // Stream<CloudUser?> getUserStream({required String userId}) {
  //   return usersCollection.doc(userId).snapshots().map((snap) => snap.data());
  // }

  Future<CloudUser> getUser({required String userId}) async {
    try {
      final doc = await usersCollection.doc(userId).get();
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
      await usersCollection.doc(user.id).update(user.toMap());
    } catch (e) {
      throw CouldNotUpdateUserException(message: e.toString());
    }
  }

  // // **Pagination for Users**
  // Future<List<CloudUser>> getUsersPaginated({
  //   required int limit,
  //   DocumentSnapshot<CloudUser>? startAfterDoc,
  // }) async {
  //   try {
  //     Query<CloudUser> query = usersCollection
  //         .orderBy('username') // Ensure you have an index on 'username'
  //         .limit(limit);

  //     if (startAfterDoc != null) {
  //       query = query.startAfterDocument(startAfterDoc);
  //     }

  //     final querySnapshot = await query.get();
  //     return querySnapshot.docs.map((doc) => doc.data()).toList();
  //   } catch (_) {
  //     throw CouldNotGetAllUsersException();
  //   }
  // }

  // **Username Methods**

  Future<bool> isUsernameTaken(String username) async {
    try {
      final doc = await usernamesCollection.doc(username).get();
      return doc.exists;
    } catch (_) {
      throw CouldNotCheckUsernameException();
    }
  }

  Future<void> updateUserAndPrivateDataInTransaction({
    required CloudUser user,
    required UserPrivateData privateData,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Update user document
        final userRef = usersCollection.doc(user.id);
        transaction.update(userRef, user.toMap());

        // Update private data document
        final privateDataRef = userRef.collection('private').doc('privateData');
        transaction.update(privateDataRef, privateData.toMap());
      });
    } catch (e) {
      throw CouldNotUpdateUserException();
    }
  }

  // **Private Data Methods**

  Future<UserPrivateData> getPrivateData({required String userId}) async {
    try {
      final doc = await usersCollection.doc(userId).collection('private').doc('privateData').get();
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

  // **Event Methods**

  Stream<Iterable<LivitEvent>> getEventsStream({required String creatorId}) {
    return eventsCollection.where('creatorId', isEqualTo: creatorId).snapshots().map((snapshot) => snapshot.docs.map((doc) => doc.data()));
  }

  Future<Iterable<LivitEvent>> getEvents({required String creatorId}) async {
    try {
      final querySnapshot = await eventsCollection.where('creatorId', isEqualTo: creatorId).get();
      return querySnapshot.docs.map((doc) => doc.data());
    } catch (_) {
      throw CouldNotGetAllEventsException();
    }
  }

  Future<LivitEvent> createEvent({
    required LivitEvent event,
  }) async {
    try {
      final docRef = await eventsCollection.add(event);
      final doc = await docRef.get();
      return doc.data()!;
    } catch (_) {
      throw CouldNotCreateEventException();
    }
  }

  Future<void> updateEvent({
    required LivitEvent event,
  }) async {
    try {
      await eventsCollection.doc(event.id).update(event.toMap());
    } catch (_) {
      throw CouldNotUpdateEventException();
    }
  }

  Future<void> deleteEvent({required String eventId}) async {
    try {
      await eventsCollection.doc(eventId).delete();
    } catch (_) {
      throw CouldNotDeleteEventException();
    }
  }

  Future<PaginatedEvents> getEventsPaginated({
    required String creatorId,
    required int limit,
    DocumentSnapshot<LivitEvent>? startAfterDoc,
  }) async {
    try {
      Query<LivitEvent> query = eventsCollection
          .where('creatorId', isEqualTo: creatorId)
          .orderBy('eventName') // Ensure you have an index on 'eventName'
          .limit(limit);

      if (startAfterDoc != null) {
        query = query.startAfterDocument(startAfterDoc);
      }

      final querySnapshot = await query.get();
      return PaginatedEvents(
        events: querySnapshot.docs.map((doc) => doc.data()).toList(),
        lastDocument: querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null,
      );
    } catch (_) {
      throw CouldNotGetAllEventsException();
    }
  }

  // **Ticket Methods**

  Stream<Iterable<LivitTicket>> getTicketsStream({required String userId}) {
    return ticketsCollection.where('userId', isEqualTo: userId).snapshots().map((snapshot) => snapshot.docs.map((doc) => doc.data()));
  }

  Future<Iterable<LivitTicket>> getTickets({required String userId}) async {
    try {
      final querySnapshot = await ticketsCollection.where('userId', isEqualTo: userId).get();
      return querySnapshot.docs.map((doc) => doc.data());
    } catch (_) {
      throw CouldNotGetAllTicketsException();
    }
  }

  Future<LivitTicket> createTicket({
    required LivitTicket ticket,
  }) async {
    try {
      final docRef = await ticketsCollection.add(ticket);
      final doc = await docRef.get();
      return doc.data()!;
    } catch (_) {
      throw CouldNotCreateTicketException();
    }
  }

  Future<void> updateTicket({
    required LivitTicket ticket,
  }) async {
    try {
      await ticketsCollection.doc(ticket.ticketId).update(ticket.toMap());
    } catch (_) {
      throw CouldNotUpdateTicketException();
    }
  }

  Future<void> deleteTicket({required String ticketId}) async {
    try {
      await ticketsCollection.doc(ticketId).delete();
    } catch (_) {
      throw CouldNotDeleteTicketException();
    }
  }

  Future<List<LivitTicket>> getTicketsPaginated({
    required String userId,
    required int limit,
    DocumentSnapshot<LivitTicket>? startAfterDoc,
  }) async {
    try {
      Query<LivitTicket> query = ticketsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('ticketTypeName') // Ensure you have an index on 'ticketTypeName'
          .limit(limit);

      if (startAfterDoc != null) {
        query = query.startAfterDocument(startAfterDoc);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (_) {
      throw CouldNotGetAllTicketsException();
    }
  }
}

class PaginatedEvents {
  final List<LivitEvent> events;
  final DocumentSnapshot<LivitEvent>? lastDocument;

  PaginatedEvents({
    required this.events,
    this.lastDocument,
  });
}
