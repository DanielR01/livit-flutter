import 'package:cloud_firestore/cloud_firestore.dart';

class PrivateCloudTicket {
  final String ticketId;
  final String eventId;
  final String ownerId;
  final String description;
  final Map<String, dynamic> entranceLocation;
  final String ticketType;
  final String ticketStatus;
  final Map<String, dynamic> ticketPrice;
  final String eventDateName;
  final Timestamp ownedAt;
  final List<String> scannableBy;
  final String? scannedBy;
  final Timestamp? scannedAt;
  final Timestamp validFrom;
  final Timestamp validTo;
  final Timestamp minActivationTime;
  final Timestamp? activatedAt;
  final double? randomNumber;

  PrivateCloudTicket({
    required this.ticketId,
    required this.eventId,
    required this.ownerId,
    required this.ticketType,
    required this.ticketStatus,
    required this.ticketPrice,
    required this.eventDateName,
    required this.description,
    required this.entranceLocation,
    required this.ownedAt,
    required this.scannableBy,
    required this.scannedBy,
    required this.scannedAt,
    required this.validFrom,
    required this.validTo,
    required this.minActivationTime,
    required this.activatedAt,
    required this.randomNumber,
  });

  factory PrivateCloudTicket.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PrivateCloudTicket(
      ticketId: data['ticketId'],
      eventId: data['eventId'],
      ownerId: data['ownerId'],
      ticketType: data['ticketType'],
      ticketStatus: data['ticketStatus'],
      ticketPrice: data['ticketPrice'],
      eventDateName: data['eventDateName'],
      description: data['description'],
      entranceLocation: data['entranceLocation'],
      ownedAt: data['ownedAt'],
      scannableBy: data['scannableBy'],
      scannedBy: data['scannedBy'],
      scannedAt: data['scannedAt'],
      validFrom: data['validFrom'],
      validTo: data['validTo'],
      minActivationTime: data['minActivationTime'],
      activatedAt: data['activatedAt'],
      randomNumber: data['randomNumber'],
    );
  }

  Map<String, Object?> toMap() {
    return {
      'ticketId': ticketId,
      'eventId': eventId,
      'ownerId': ownerId,
      'ticketType': ticketType,
      'ticketStatus': ticketStatus,
      'ticketPrice': ticketPrice,
      'eventDateName': eventDateName,
      'description': description,
      'entranceLocation': entranceLocation,
      'ownedAt': ownedAt,
      'scannableBy': scannableBy,
      'scannedBy': scannedBy,
      'scannedAt': scannedAt,
      'validFrom': validFrom,
      'validTo': validTo,
      'minActivationTime': minActivationTime,
      'activatedAt': activatedAt,
      'randomNumber': randomNumber,
    };
  }

  @override
  String toString() {
    return 'PrivateCloudTicket(ticketId: $ticketId, eventId: $eventId, ownerId: $ownerId, ticketType: $ticketType, ticketStatus: $ticketStatus, ticketPrice: $ticketPrice, eventDateName: $eventDateName, description: $description, entranceLocation: $entranceLocation, ownedAt: $ownedAt, scannableBy: $scannableBy, scannedBy: $scannedBy, scannedAt: $scannedAt, validFrom: $validFrom, validTo: $validTo, minActivationTime: $minActivationTime, activatedAt: $activatedAt, randomNumber: $randomNumber)';
  }
}

class PublicCloudTicket {
  final String ticketId;
  final String eventId;
  final String ownerId;
  final String ticketType;
  final String ticketStatus;
  final String eventDateName;
  final String description;
  final Map<String, dynamic> entranceLocation;
  final List<String> scannableBy;
  final String? scannedBy;
  final Timestamp? scannedAt;
  final Timestamp validFrom;
  final Timestamp validTo;
  final Timestamp minActivationTime;

  PublicCloudTicket({
    required this.ticketId,
    required this.eventId,
    required this.ownerId,
    required this.ticketType,
    required this.ticketStatus,
    required this.eventDateName,
    required this.description,
    required this.entranceLocation,
    required this.scannableBy,
    required this.scannedBy,
    required this.scannedAt,
    required this.validFrom,
    required this.validTo,
    required this.minActivationTime,
  });

  factory PublicCloudTicket.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PublicCloudTicket(
      ticketId: data['ticketId'],
      eventId: data['eventId'],
      ownerId: data['ownerId'],
      ticketType: data['ticketType'],
      ticketStatus: data['ticketStatus'],
      eventDateName: data['eventDateName'],
      description: data['description'],
      entranceLocation: data['entranceLocation'],
      scannableBy: data['scannableBy'],
      scannedBy: data['scannedBy'],
      scannedAt: data['scannedAt'],
      validFrom: data['validFrom'],
      validTo: data['validTo'],
      minActivationTime: data['minActivationTime'],
    );
  }

  Map<String, Object?> toMap() {
    return {
      'ticketId': ticketId,
      'eventId': eventId,
      'ownerId': ownerId,
      'ticketType': ticketType,
      'ticketStatus': ticketStatus,
      'eventDateName': eventDateName,
      'description': description,
      'entranceLocation': entranceLocation,
      'scannableBy': scannableBy,
      'scannedBy': scannedBy,
      'scannedAt': scannedAt,
      'validFrom': validFrom,
      'validTo': validTo,
      'minActivationTime': minActivationTime,
    };
  }

  @override
  String toString() {
    return 'PublicCloudTicket(ticketId: $ticketId, eventId: $eventId, ownerId: $ownerId, ticketType: $ticketType, ticketStatus: $ticketStatus, eventDateName: $eventDateName, description: $description, entranceLocation: $entranceLocation, scannableBy: $scannableBy, scannedBy: $scannedBy, scannedAt: $scannedAt, validFrom: $validFrom, validTo: $validTo, minActivationTime: $minActivationTime)';
  }
}
