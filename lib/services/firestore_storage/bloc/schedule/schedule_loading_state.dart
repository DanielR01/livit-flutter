part of 'schedule_bloc.dart';

class ScheduleLoadingState {
  final LoadingState isOpen;
  final LoadingState monthSchedule;
  final LoadingState nextOpeningDate;

  ScheduleLoadingState({required this.isOpen, required this.monthSchedule, required this.nextOpeningDate});

  ScheduleLoadingState copyWith({LoadingState? isOpen, LoadingState? monthSchedule, LoadingState? nextOpeningDate}) {
    return ScheduleLoadingState(
      isOpen: isOpen ?? this.isOpen,
      monthSchedule: monthSchedule ?? this.monthSchedule,
      nextOpeningDate: nextOpeningDate ?? this.nextOpeningDate,
    );
  }
}
