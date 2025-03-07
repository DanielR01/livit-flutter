part of 'schedule_bloc.dart';

abstract class ScheduleEvent {}

class CheckLocationOpenForPromoter extends ScheduleEvent {
  final String locationId;
  final DateTime date;

  CheckLocationOpenForPromoter({
    required this.locationId,
    required this.date,
  });
}

class LoadMonthScheduleForPromoter extends ScheduleEvent {
  final String locationId;
  final DateTime month;

  LoadMonthScheduleForPromoter({
    required this.locationId,
    required this.month,
  });
}

class GetNextOpeningDateForPromoter extends ScheduleEvent {
  final String locationId;
  final DateTime fromDate;

  GetNextOpeningDateForPromoter({
    required this.locationId,
    required this.fromDate,
  });
}
