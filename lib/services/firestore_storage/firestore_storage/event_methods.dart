import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livit/services/firestore_storage/livit_event.dart';
import 'package:livit/services/firestore_storage/firestore_storage/collections.dart';
import 'package:livit/services/firestore_storage/firestore_storage/exceptions/firestore_exceptions.dart';

class EventMethods {
  static final EventMethods _shared = EventMethods._sharedInstance();
  EventMethods._sharedInstance();
  factory EventMethods() => _shared;

  final Collections _collections = Collections();

  Stream<Iterable<LivitEvent>> getEventsStream({required String creatorId}) {
    return _collections.eventsCollection
        .where('creatorId', isEqualTo: creatorId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()));
  }

  Future<Iterable<LivitEvent>> getEvents({required String creatorId}) async {
    try {
      final querySnapshot = await _collections.eventsCollection
          .where('creatorId', isEqualTo: creatorId)
          .get();
      return querySnapshot.docs.map((doc) => doc.data());
    } catch (_) {
      throw CouldNotGetAllEventsException();
    }
  }

  Future<LivitEvent> createEvent({required LivitEvent event}) async {
    try {
      final docRef = await _collections.eventsCollection.add(event);
      final doc = await docRef.get();
      return doc.data()!;
    } catch (_) {
      throw CouldNotCreateEventException();
    }
  }

  Future<void> updateEvent({required LivitEvent event}) async {
    try {
      await _collections.eventsCollection.doc(event.id).update(event.toMap());
    } catch (_) {
      throw CouldNotUpdateEventException();
    }
  }

  Future<void> deleteEvent({required String eventId}) async {
    try {
      await _collections.eventsCollection.doc(eventId).delete();
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
      Query<LivitEvent> query = _collections.eventsCollection
          .where('creatorId', isEqualTo: creatorId)
          .orderBy('eventName')
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
}

class PaginatedEvents {
  final List<LivitEvent> events;
  final DocumentSnapshot<LivitEvent>? lastDocument;

  PaginatedEvents({
    required this.events,
    this.lastDocument,
  });
} 