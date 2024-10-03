import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livit/services/cloud/livit_event.dart';
import 'package:livit/services/cloud/livit_ticket.dart';
import 'package:livit/services/cloud/livit_user.dart';
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

  final CollectionReference<LivitUser> usersCollection = FirebaseFirestore.instance.collection('users').withConverter<LivitUser>(
        fromFirestore: (snap, _) => LivitUser.fromDocument(snap),
        toFirestore: (user, _) => user.toMap(),
      );

  final CollectionReference<LivitTicket> ticketsCollection = FirebaseFirestore.instance.collection('tickets').withConverter<LivitTicket>(
        fromFirestore: (snap, _) => LivitTicket.fromDocument(snap),
        toFirestore: (ticket, _) => ticket.toMap(),
      );

  final CollectionReference<Map<String, dynamic>> usernamesCollection = FirebaseFirestore.instance.collection('usernames');

  // **User Methods**

  Stream<LivitUser?> getUserStream({required String userId}) {
    return usersCollection.doc(userId).snapshots().map((snap) => snap.data());
  }

  Future<LivitUser> getUser({required String userId}) async {
    try {
      final doc = await usersCollection.doc(userId).get();
      if (doc.exists) {
        return doc.data()!;
      } else {
        throw UserNotFoundException();
      }
    } on UserNotFoundException {
      rethrow;
    } catch (e) {
      throw CouldNotGetUserException();
    }
  }

  Future<void> createUser({required LivitUser user}) async {
    try {
      await usersCollection.doc(user.id).set(user);
    } catch (_) {
      throw CouldNotCreateUserException();
    }
  }

  Future<void> updateUser({required LivitUser user}) async {
    try {
      await usersCollection.doc(user.id).update(user.toMap());
    } catch (_) {
      throw CouldNotUpdateUserException();
    }
  }

  // **Username Methods**

  /// Attempts to reserve a username and create a user in a single transaction.
  /// Throws [UsernameAlreadyExistsException] if the username is taken.
  Future<void> createUserWithUsername({
    required String userId,
    required String username,
    required LivitUser user,
  }) async {
    final usernameDoc = usernamesCollection.doc(username.toLowerCase());

    // Changed: Use untyped DocumentReference<Object?> for userDoc
    final userDoc = _firestore.collection('users').doc(userId);

    try {
      await _firestore.runTransaction((transaction) async {
        // Check if username already exists
        final usernameSnapshot = await transaction.get(usernameDoc);
        if (usernameSnapshot.exists) {
          throw UsernameAlreadyExistsException();
        }

        // Check if user already exists
        // Changed: Use untyped DocumentReference for fetching user
        final userSnapshot = await transaction.get(userDoc);
        if (userSnapshot.exists) {
          throw UserAlreadyExistsException();
        }

        // Reserve the username
        transaction.set(usernameDoc, {'userId': userId});

        // Create the user
        transaction.set(userDoc, user.toMap(), SetOptions(merge: true));
      });
    } on UsernameAlreadyExistsException {
      rethrow;
    } catch (e) {
      throw CouldNotCreateUserException();
    }
  }

  // **Pagination for Users**
  Future<List<LivitUser>> getUsersPaginated({
    required int limit,
    DocumentSnapshot<LivitUser>? startAfterDoc,
  }) async {
    try {
      Query<LivitUser> query = usersCollection
          .orderBy('username') // Ensure you have an index on 'username'
          .limit(limit);

      if (startAfterDoc != null) {
        query = query.startAfterDocument(startAfterDoc);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (_) {
      throw CouldNotGetAllUsersException();
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
