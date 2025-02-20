import 'package:cloud_firestore/cloud_firestore.dart';

abstract class TicketEvent {}

class FetchTicketsCountByDate extends TicketEvent {
  final Timestamp startDate;
  final Timestamp endDate;

  FetchTicketsCountByDate({required this.startDate, required this.endDate});
}

class RefreshTicketsCountByDate extends TicketEvent {}

class FetchTicketsCountByEvent extends TicketEvent {
  final String eventId;
  final Timestamp? startDate;
  final Timestamp? endDate;

  FetchTicketsCountByEvent({required this.eventId, this.startDate, this.endDate});
}
