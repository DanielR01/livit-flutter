import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livit/services/cloud/cloud_storage_constants.dart';

class CloudEvent {
  final String documentId;
  final String creatorId;
  final String title;
  final String location;
  const CloudEvent({
    required this.documentId,
    required this.creatorId,
    required this.title,
    required this.location,
  });
  CloudEvent.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        creatorId = snapshot.data()[creatorIdFieldName],
        title = snapshot.data()[titleFieldName] as String,
        location = snapshot.data()[locationFieldName] as String;
}
