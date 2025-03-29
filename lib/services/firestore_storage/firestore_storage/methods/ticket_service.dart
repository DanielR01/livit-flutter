// lib/services/firestore/ticket_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livit/utilities/debug/livit_debugger.dart';

class TicketService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _debugger = const LivitDebugger('TicketService');

  Future<int> getTicketsSoldInDateRange({
    required String promoterId,
    required Timestamp startDate,
    required Timestamp endDate,
    required String locationId,
  }) async {
    try {
      _debugger.debPrint('Getting tickets sold in date range: $startDate to $endDate', DebugMessageType.downloading);
      final querySnapshot = await _firestore
          .collection('tickets')
          .where('promoterId', isEqualTo: promoterId)
          .where('locationId', isEqualTo: locationId)
          .where('purchasedAt', isGreaterThanOrEqualTo: startDate)
          .where('purchasedAt', isLessThanOrEqualTo: endDate)
          .get();
      _debugger.debPrint('Tickets sold in date range: ${querySnapshot.docs.length}', DebugMessageType.response);
      return querySnapshot.docs.length;
    } catch (e) {
      _debugger.debPrint('Error getting tickets count: $e', DebugMessageType.error);
      rethrow;
    }
  }

  Future<int> getTicketsSoldForEvent({
    required String eventId,
    required String promoterId,
  }) async {
    _debugger.debPrint('Getting tickets sold for event: $eventId', DebugMessageType.downloading);
    try {
      final querySnapshot = await _firestore
          .collection('tickets')
          .where(
            'eventId',
            isEqualTo: eventId,
          )
          .where('promoterId', isEqualTo: promoterId)
          .get();
      _debugger.debPrint('Tickets sold for event: ${querySnapshot.docs.length}', DebugMessageType.response);
      return querySnapshot.docs.length;
    } catch (e) {
      _debugger.debPrint('Error getting tickets count: $e', DebugMessageType.error);
      rethrow;
    }
  }
}
