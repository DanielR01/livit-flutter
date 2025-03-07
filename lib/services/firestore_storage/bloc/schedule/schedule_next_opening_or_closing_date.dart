part of 'schedule_bloc.dart';

class ScheduleNextOpeningOrClosingDate {
  final DateTime date;
  final bool isOpening;
  final bool isClosing;

  ScheduleNextOpeningOrClosingDate({  required this.date, required this.isOpening, required this.isClosing});

  factory ScheduleNextOpeningOrClosingDate.opening({required DateTime date}) {
    return ScheduleNextOpeningOrClosingDate(date: date, isOpening: true, isClosing: false);
  }

  factory ScheduleNextOpeningOrClosingDate.closing({required DateTime date}) {
    return ScheduleNextOpeningOrClosingDate(date: date, isOpening: false, isClosing: true);
  }

  factory ScheduleNextOpeningOrClosingDate.fromDate({required DateTime date, required TimeSlot timeSlot}){
    if(date.isBefore(timeSlot.startDateTime)){
      return ScheduleNextOpeningOrClosingDate.opening(date: timeSlot.startDateTime);
    }
    return ScheduleNextOpeningOrClosingDate.closing(date: timeSlot.endDateTime);
  }

  @override
  String toString() {
    return 'ScheduleNextOpeningOrClosingDate(date: $date, isOpening: $isOpening, isClosing: $isClosing)';
  }
}
