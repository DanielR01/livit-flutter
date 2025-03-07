part of 'schedule_bloc.dart';

abstract class ScheduleState {}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoaded extends ScheduleState {
  final Map<String, ScheduleLoadingState> loadingStates;
  final Map<String, List<DaySchedule>> monthSchedules;
  final Map<String, List<DaySchedule>> next30DaysSchedules;
  final Map<String, ScheduleNextOpeningOrClosingDate?> nextOpeningOrClosingDates;
  final Map<String, bool> isOpen;

  ScheduleLoaded({
    required this.loadingStates,
    required this.monthSchedules,
    required this.next30DaysSchedules,
    required this.nextOpeningOrClosingDates,
    required this.isOpen,
  });
}
