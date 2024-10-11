import 'package:cloud_firestore/cloud_firestore.dart';

class CloudReaction {
  final String reactionId;
  final String userId;
  final String eventId;
  final String reactionType;
  final Timestamp reactionDate;

  CloudReaction({
    required this.reactionId,
    required this.userId,
    required this.eventId,
    required this.reactionType,
    required this.reactionDate,
  });

  factory CloudReaction.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CloudReaction(
      reactionId: data['reactionId'],
      userId: data['userId'],
      eventId: data['eventId'],
      reactionType: data['reactionType'],
      reactionDate: data['reactionDate'],
    );
  }

  Map<String, Object?> toMap() {
    return {
      'reactionId': reactionId,
      'userId': userId,
      'eventId': eventId,
      'reactionType': reactionType,
      'reactionDate': reactionDate,
    };
  }

  @override
  String toString() {
    return 'CloudReaction(reactionId: $reactionId, userId: $userId, eventId: $eventId, reactionType: $reactionType, reactionDate: $reactionDate)';
  }
}