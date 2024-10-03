import 'package:cloud_firestore/cloud_firestore.dart';

class LivitTicket {
  final String ticketId;
  final String eventId;
  final String userId;
  final String ticketTypeName;
  final List<String> scannableBy; 
  final String? scannedBy; 
  final DateTime? scanTimestamp; 
  final bool isScanned;

  LivitTicket({
    required this.ticketId,
    required this.eventId,
    required this.userId,
    required this.ticketTypeName,
    required this.scannableBy,
    this.scannedBy,
    this.scanTimestamp,
    required this.isScanned,
  });

  factory LivitTicket.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return LivitTicket(
      ticketId: data['ticketId'],
      eventId: data['eventId'],
      userId: data['userId'],
      ticketTypeName: data['ticketTypeName'],
      scannableBy: List<String>.from(data['scannableBy']),
      scannedBy: data['scannedBy'],
      scanTimestamp: data['scanTimestamp'] != null
          ? DateTime.parse(data['scanTimestamp'])
          : null,
      isScanned: data['isScanned'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ticketId': ticketId,
      'eventId': eventId,
      'userId': userId,
      'ticketTypeName': ticketTypeName,
      'scannableBy': scannableBy,
      if (scannedBy != null) 'scannedBy': scannedBy,
      if (scanTimestamp != null)
        'scanTimestamp': scanTimestamp!.toIso8601String(),
      'isScanned': isScanned,
    };
  }
}
