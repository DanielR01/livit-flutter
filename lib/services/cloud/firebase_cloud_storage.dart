import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livit/services/cloud/cloud_event.dart';
import 'package:livit/services/cloud/cloud_storage_constants.dart';
import 'package:livit/services/cloud/cloud_storage_exceptions.dart';

enum UserType {
  customer,
  promoter,
}

class FirebaseCloudStorage {
  static final FirebaseCloudStorage _shared = FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;

  final events = FirebaseFirestore.instance.collection('events');

  Future<void> deleteEvent({required String documentId}) async {
    try {
      await events.doc(documentId).delete();
    } catch (_) {
      throw CouldNotDeleteEventException();
    }
  }

  Future<void> updateEvent({
    required String documentId,
    required String title,
    required location,
  }) async {
    try {
      await events.doc(documentId).update({
        titleFieldName: title,
        locationFieldName: location,
      });
    } catch (_) {
      throw CouldNotUpdateEventException();
    }
  }

  Stream<Iterable<CloudEvent>> allEvents({required String creatorId}) => events.snapshots().map(
        (event) => event.docs.map((doc) => CloudEvent.fromSnapshot(doc)).where(
              (event) => event.creatorId == creatorId,
            ),
      );

  Future<Iterable<CloudEvent>> getEvents({required String creatorId}) async {
    try {
      return await events.where(creatorIdFieldName, isEqualTo: creatorId).get().then(
            (value) => value.docs.map(
              (doc) => CloudEvent.fromSnapshot(doc),
            ),
          );
    } catch (e) {
      throw CouldNotGetAllEventsException();
    }
  }

  Future<CloudEvent> createEvent({
    required String creatorId,
    required String title,
    required String location,
  }) async {
    try {
      final document = await events.add({
        creatorIdFieldName: creatorId,
        titleFieldName: title,
        locationFieldName: location,
      });
      final fetchedEvent = await document.get();
      return CloudEvent(
        documentId: fetchedEvent.id,
        creatorId: creatorId,
        title: title,
        location: location,
      );
    } catch (_) {
      throw CouldNotCreateEventException();
    }
  }
}
