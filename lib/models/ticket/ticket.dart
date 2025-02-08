import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livit/models/price/price.dart';
import 'package:livit/models/ticket/ticket_status.dart';

class LivitTicket {
  final String ticketId;
  final String eventId;
  final String ownerId;
  final String promoterId;
  final String ticketType;
  final TicketStatus ticketStatus;
  final LivitPrice ticketPrice;
  final String description;
  final String eventDateName;
  final DateTime ownedAt;
  final DateTime purchasedAt;
  final String? scannedBy;
  final DateTime? scannedAt;
  final Timestamp scanStartTime;
  final Timestamp scanExpiryTime;
  final Timestamp minActivationTime; // Time after which the ticket can be activated, only after activation it can be scanned
  final Timestamp? activatedAt; // Time at which the ticket was activated
  final String? locationId;
  final GeoPoint? entranceLocation;

  LivitTicket({
    required this.ticketId,
    required this.eventId,
    required this.ownerId,
    required this.promoterId,
    required this.ticketType,
    required this.ticketStatus,
    required this.ticketPrice,
    required this.description,
    required this.eventDateName,
    required this.ownedAt,
    required this.purchasedAt,
    required this.scannedBy,
    required this.scannedAt,
    required this.scanStartTime,
    required this.scanExpiryTime,
    required this.minActivationTime,
    required this.activatedAt,
    required this.locationId,
    required this.entranceLocation,
  });

  factory LivitTicket.fromMap(Map<String, dynamic> map) {
    return LivitTicket(
      ticketId: map['ticketId'],
      eventId: map['eventId'],
      ownerId: map['ownerId'],
      promoterId: map['promoterId'],
      ticketType: map['ticketType'],
      ticketStatus: TicketStatus.values.byName(map['ticketStatus']),
      ticketPrice: LivitPrice.fromMap(map['ticketPrice']),
      description: map['description'],
      eventDateName: map['eventDateName'],
      ownedAt: map['ownedAt'],
      purchasedAt: map['purchasedAt'],
      scannedBy: map['scannedBy'],
      scannedAt: map['scannedAt'],
      scanStartTime: map['scanStartTime'],
      scanExpiryTime: map['scanExpiryTime'],
      minActivationTime: map['minActivationTime'],
      activatedAt: map['activatedAt'],
      locationId: map['locationId'],
      entranceLocation: map['entranceLocation'],
    );
  }

  factory LivitTicket.fromDocument(DocumentSnapshot<Map<String, dynamic>> document) {
    return LivitTicket.fromMap(document.data()!);
  }

  Map<String, dynamic> toMap() {
    return {
      'ticketId': ticketId,
      'eventId': eventId,
      'ownerId': ownerId,
      'promoterId': promoterId,
      'ticketType': ticketType,
      'ticketStatus': ticketStatus.name,
      'ticketPrice': ticketPrice.toMap(),
      'description': description,
      'eventDateName': eventDateName,
      'ownedAt': ownedAt,
      'purchasedAt': purchasedAt,
      'scannedBy': scannedBy,
      'scannedAt': scannedAt,
      'scanStartTime': scanStartTime,
      'scanExpiryTime': scanExpiryTime,
      'minActivationTime': minActivationTime,
      'activatedAt': activatedAt,
      'locationId': locationId,
      'entranceLocation': entranceLocation,
    };
  }
}
