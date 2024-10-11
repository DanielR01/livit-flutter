import 'package:cloud_firestore/cloud_firestore.dart';

class CloudFriendship {
  final String friendshipId;
  final String requesterId;
  final String requestedId;
  final String status;

  CloudFriendship({
    required this.friendshipId,
    required this.requesterId,
    required this.requestedId,
    required this.status,
  });

  factory CloudFriendship.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CloudFriendship(
      friendshipId: data['friendshipId'],
      requesterId: data['requesterId'],
      requestedId: data['requestedId'],
      status: data['status'],
    );
  }

  Map<String, Object?> toMap() {
    return {
      'friendshipId': friendshipId,
      'requesterId': requesterId,
      'requestedId': requestedId,
      'status': status,
    };
  }

  @override
  String toString() {
    return 'CloudFriendship(friendshipId: $friendshipId, requesterId: $requesterId, requestedId: $requestedId, status: $status)';
  }
}
