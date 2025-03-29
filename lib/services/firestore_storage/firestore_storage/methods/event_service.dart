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

      // Option 1: If you've denormalized the data by storing an array of locationIds at the root level
      QuerySnapshot<LivitEvent> querySnapshot;
      try {
        // Try to query using a denormalized field if it exists
        querySnapshot = await _collections.eventsCollection.where('locationIds', arrayContains: locationId).get();
        debugPrint('📥 [EventService] Query using locationIds field successful');
      } catch (e) {
        debugPrint('📥 [EventService] Could not query by locationIds, falling back to client-side filtering: $e');
        // Fall back to querying all events and filtering client-side
        querySnapshot = await _collections.eventsCollection.get();
      }

      if (querySnapshot.docs.isEmpty) {
        debugPrint('📥 [EventService] No events found');
        return [];
      }

      // Filter client-side if needed
      final events = querySnapshot.docs
          .map((doc) => doc.data())
          .where((event) =>
              // Keep this filter even if the query used locationIds field as an extra safety check
              event.locations.any((location) => location.locationId == locationId) &&
              event.dates.any((date) => date.endTime.toDate().isAfter(now)))
          .toList();

      debugPrint('📥 [EventService] Events found for location $locationId: ${events.length}');

      // Sort by the nearest upcoming date
      events.sort((a, b) {
        final aNextDate = a.dates
            .where((date) => date.endTime.toDate().isAfter(now))
            .reduce((curr, next) => curr.endTime.toDate().isBefore(next.endTime.toDate()) ? curr : next);

        final bNextDate = b.dates
            .where((date) => date.endTime.toDate().isAfter(now))
            .reduce((curr, next) => curr.endTime.toDate().isBefore(next.endTime.toDate()) ? curr : next);

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

  Future<List<LivitEvent>> getEventsByIds(List<String> eventIds) async {
    try {
      debugPrint('📥 [EventService] Getting events by ids: $eventIds');
      final events = await _collections.eventsCollection.where('id', whereIn: eventIds).get();
      debugPrint('📥 [EventService] Found ${events.docs.length} events by ids: $eventIds');
      return events.docs.map((doc) => doc.data()).toList();
    } catch (_) {
      debugPrint('❌ [EventService] Could not get events by ids: $eventIds');
      throw CouldNotGetEventsByIdsException();
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
