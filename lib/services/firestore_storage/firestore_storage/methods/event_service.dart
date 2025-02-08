import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:livit/models/event/event.dart';
import 'package:livit/services/firestore_storage/firestore_storage/collections.dart';
import 'package:livit/services/firestore_storage/firestore_storage/exceptions/firestore_exceptions.dart';

class EventService {
  static final EventService _shared = EventService._sharedInstance();
  EventService._sharedInstance();
  factory EventService() => _shared;

  final Collections _collections = Collections();

  Future<List<LivitEvent>> getNextEventsByLocation({required String locationId}) async {
    debugPrint('📥 [EventService] Getting next events by location: $locationId');
    try {
      final now = DateTime.now();

      // Query events where locations array contains a map with all required fields
      final querySnapshot = await _collections.eventsCollection.where('location.locationId', isEqualTo: locationId).get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint('📥 [EventService] No events found');
        return [];
      }

      debugPrint('📥 [EventService] Events found: ${querySnapshot.docs.length}');

      // Post-process to filter by dates and sort
      final events = querySnapshot.docs
          .map((doc) => doc.data())
          .where((event) => event.dates.any((date) => date.endTime.toDate().isAfter(now)))
          .toList();

      // Sort by the nearest upcoming date
      events.sort((a, b) {
        final aNextDate =
            a.dates.where((date) => date.endTime.toDate().isAfter(now)).reduce((curr, next) => curr.endTime.toDate().isBefore(next.endTime.toDate()) ? curr : next);

        final bNextDate =
            b.dates.where((date) => date.endTime.toDate().isAfter(now)).reduce((curr, next) => curr.endTime.toDate().isBefore(next.endTime.toDate()) ? curr : next);

        return aNextDate.endTime.compareTo(bNextDate.endTime);
      });

      return events.take(10).toList(); // Limit to 10 results after sorting
    } catch (e) {
      debugPrint('📥 [EventService] Error getting events: $e');
      throw CouldNotGetEventsByLocationException();
    }
  }

  Stream<Iterable<LivitEvent>> getEventsStream({required String creatorId}) {
    return _collections.eventsCollection
        .where('creatorId', isEqualTo: creatorId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()));
  }

  Future<Iterable<LivitEvent>> getEvents({required String creatorId}) async {
    try {
      final querySnapshot = await _collections.eventsCollection.where('creatorId', isEqualTo: creatorId).get();
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
      Query<LivitEvent> query = _collections.eventsCollection.where('creatorId', isEqualTo: creatorId).orderBy('eventName').limit(limit);

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
