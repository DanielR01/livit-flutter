import 'package:cloud_firestore/cloud_firestore.dart';

class CloudSubscription {
  final String subscriptionId;
  final String customerId;
  final Map<String, String> target;
  final Timestamp subscribedAt; 

  CloudSubscription({
    required this.subscriptionId,
    required this.customerId,
    required this.target,
    required this.subscribedAt,
  });

  factory CloudSubscription.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CloudSubscription(
      subscriptionId: data['subscriptionId'],
      customerId: data['customerId'],
      target: data['target'],
      subscribedAt: data['subscribedAt'],
    );
  }

  Map<String, Object?> toMap() {
    return {
      'subscriptionId': subscriptionId,
      'customerId': customerId,
      'target': target,
      'subscribedAt': subscribedAt,
    };
  }

  @override
  String toString() {
    return 'CloudSubscription(subscriptionId: $subscriptionId, customerId: $customerId, target: $target, subscribedAt: $subscribedAt)';
  }
}
