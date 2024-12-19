import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livit/cloud_models/location/location.dart';
import 'package:livit/cloud_models/ticket/ticket_price.dart';
import 'package:livit/cloud_models/ticket/ticket_status.dart';

class Ticket {
  final String ticketId;
  final String eventId;
  final String ownerId;
  final String ticketType;
  final TicketStatus ticketStatus;
  final TicketPrice ticketPrice;
  final String description;
  final String eventDateName;
  final DateTime ownedAt;
  final String? scannedBy;
  final DateTime? scannedAt;
  final Timestamp scanStartTime;
  final Timestamp scanExpiryTime;
  final Timestamp minActivationTime; // Time after which the ticket can be activated, only after activation it can be scanned
  final Timestamp activatedAt; // Time at which the ticket was activated
  final Location entranceLocation;

  Ticket({
    required this.ticketId,
    required this.eventId,
    required this.ownerId,
    required this.ticketType,
    required this.ticketStatus,
    required this.ticketPrice,
    required this.description,
    required this.eventDateName,
    required this.ownedAt,
    required this.scannedBy,
    required this.scannedAt,
    required this.scanStartTime,
    required this.scanExpiryTime,
    required this.minActivationTime,
    required this.activatedAt,
    required this.entranceLocation,
  });

  factory Ticket.fromMap(Map<String, dynamic> map) {
    return Ticket(
      ticketId: map['ticketId'],
      eventId: map['eventId'],
      ownerId: map['ownerId'],
      ticketType: map['ticketType'],
      ticketStatus: TicketStatus.values.byName(map['ticketStatus']),
      ticketPrice: TicketPrice.fromMap(map['ticketPrice']),
      description: map['description'],
      eventDateName: map['eventDateName'],
      ownedAt: map['ownedAt'],
      scannedBy: map['scannedBy'],
      scannedAt: map['scannedAt'],
      scanStartTime: map['scanStartTime'],
      scanExpiryTime: map['scanExpiryTime'],
      minActivationTime: map['minActivationTime'],
      activatedAt: map['activatedAt'],
      entranceLocation: Location.fromMap(map['entranceLocation']),
    );
  }
}
