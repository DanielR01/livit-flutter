// lib/services/firestore/ticket_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class TicketService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getTicketsSoldInDateRange({
    required String promoterId,
    required Timestamp startDate,
    required Timestamp endDate,
    required String locationId,
  }) async {
    try {
      // Query tickets directly
      final querySnapshot = await _firestore
          .collection('tickets')
          .where('promoterId', isEqualTo: promoterId)
          .where('locationId', isEqualTo: locationId)
          .where('purchasedAt', isGreaterThanOrEqualTo: startDate)
          .where('purchasedAt', isLessThanOrEqualTo: endDate)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      debugPrint('❌ Error getting tickets count: $e');
      rethrow;
    }
  }

  Future<int> getTicketsSoldForEvent({
    required String eventId,
    required String promoterId,
  }) async {
    debugPrint('📥 [TicketService] Getting tickets sold for event: $eventId');
    try {
      final querySnapshot = await _firestore
          .collection('tickets')
          .where(
            'eventId',
            isEqualTo: eventId,
          )
          .where('promoterId', isEqualTo: promoterId)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      debugPrint('❌ Error getting tickets count: $e');
      rethrow;
    }
  }
}
