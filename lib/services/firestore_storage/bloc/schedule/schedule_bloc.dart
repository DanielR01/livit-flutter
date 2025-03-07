import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/models/location/schedule/location_schedule.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_bloc.dart';
import 'package:livit/services/firestore_storage/firestore_storage/firestore_storage.dart';

part 'schedule_event.dart';
part 'schedule_state.dart';
part 'schedule_loading_state.dart';
part 'schedule_next_opening_or_closing_date.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final FirestoreStorageService _storageService;
  final LocationBloc _locationBloc;

  final Map<String, ScheduleLoadingState> _loadingStates = {};
  final Map<String, List<DaySchedule>> _monthSchedules = {};
  final Map<String, List<DaySchedule>> _next30DaysSchedules = {};
  final Map<String, ScheduleNextOpeningOrClosingDate?> _nextOpeningOrClosingDates = {};
  final Map<String, bool> _isOpen = {};

  ScheduleBloc({required FirestoreStorageService firestoreStorageService, required LocationBloc locationBloc})
      : _storageService = firestoreStorageService,
        _locationBloc = locationBloc,
        super(ScheduleInitial()) {
    on<CheckLocationOpenForPromoter>(_onCheckLocationOpenForPromoter);
    on<LoadMonthScheduleForPromoter>(_onLoadMonthScheduleForPromoter);
    on<GetNextOpeningDateForPromoter>(_onGetNextOpeningDateForPromoter);
  }

  Future<void> _onCheckLocationOpenForPromoter(CheckLocationOpenForPromoter event, Emitter<ScheduleState> emit) async {
    try {
      debugPrint('🔍 [ScheduleBloc] Checking location open for promoter ${event.locationId} on ${event.date}');
      _updateLoadingState(event.locationId, isOpen: LoadingState.loading);
      emit(_createLoadedState());

      final location = _locationBloc.currentLocation;
      if (location == null) throw Exception('Location not found');

      final specialSchedule = await _storageService.locationScheduleService.getSpecialScheduleByDateTime(event.locationId, event.date);

      bool isOpen = false;

      if (specialSchedule != null) {
        isOpen = specialSchedule.timeSlot?.containsDateTime(event.date) ?? false;
      } else {
        final daySchedule = location.schedule?.weekSchedule[event.date.weekday];
        isOpen = daySchedule?.isOpen == true && (daySchedule?.timeSlot?.containsDateTime(event.date) ?? false);
      }

      _isOpen[event.locationId] = isOpen;
      _updateLoadingState(event.locationId, isOpen: LoadingState.loaded);
      emit(_createLoadedState());
      debugPrint('✅ [ScheduleBloc] Location open: $isOpen for promoter ${event.locationId} on ${event.date}');
    } catch (e) {
      debugPrint('❌ [ScheduleBloc] Error checking location open for promoter ${event.locationId} on ${event.date}: $e');
      _updateLoadingState(event.locationId, isOpen: LoadingState.error);
      emit(_createLoadedState());
    }
  }

  Future<void> _onLoadMonthScheduleForPromoter(LoadMonthScheduleForPromoter event, Emitter<ScheduleState> emit) async {
    try {
      debugPrint('🔍 [ScheduleBloc] Loading month schedule for promoter ${event.locationId} on ${event.month}');
      _updateLoadingState(event.locationId, monthSchedule: LoadingState.loading);
      emit(_createLoadedState());

      final location = _locationBloc.currentLocation;
      if (location == null) throw Exception('Location not found');

      final List<SpecialDaySchedule> monthSpecialSchedule = await _storageService.locationScheduleService.getMonthSpecialSchedules(
        event.locationId,
        event.month,
      );

      final List<DaySchedule> monthSchedule =
          await _buildNext30DaysSchedule(event.month, location.schedule ?? LocationSchedule(weekSchedule: {}), monthSpecialSchedule);

      _monthSchedules[event.locationId] = monthSchedule;
      _updateLoadingState(event.locationId, monthSchedule: LoadingState.loaded);
      emit(_createLoadedState());
      debugPrint('✅ [ScheduleBloc] Month schedule loaded for promoter ${event.locationId} on ${event.month}');
    } catch (e) {
      debugPrint('❌ [ScheduleBloc] Error loading month schedule for promoter ${event.locationId} on ${event.month}: $e');
      _updateLoadingState(event.locationId, monthSchedule: LoadingState.error);
      emit(_createLoadedState());
    }
  }

  Future<void> _onGetNextOpeningDateForPromoter(GetNextOpeningDateForPromoter event, Emitter<ScheduleState> emit) async {
    try {
      debugPrint('🔍 [ScheduleBloc] Getting next opening date for promoter ${event.locationId} from ${event.fromDate}');
      _updateLoadingState(event.locationId, nextOpeningDate: LoadingState.loading);
      emit(_createLoadedState());

      final location = _locationBloc.currentLocation;
      if (location == null) throw Exception('Location not found');

      final List<SpecialDaySchedule> specialSchedules = await _storageService.locationScheduleService.getNext30DaysSpecialSchedules(
        event.locationId,
        event.fromDate,
      );

      final List<DaySchedule> next30DaysSchedule =
          await _buildNext30DaysSchedule(event.fromDate, location.schedule ?? LocationSchedule(weekSchedule: {}), specialSchedules);
      _next30DaysSchedules[event.locationId] = next30DaysSchedule;
      DaySchedule? nextOpeningOrClosingDate;
      for (final schedule in next30DaysSchedule) {
        if (schedule.timeSlot != null) {
          nextOpeningOrClosingDate = schedule;
          break;
        }
      }
      if (nextOpeningOrClosingDate == null) {
        _nextOpeningOrClosingDates[event.locationId] = null;
      } else {
        _nextOpeningOrClosingDates[event.locationId] = ScheduleNextOpeningOrClosingDate.fromDate(
          date: event.fromDate,
          timeSlot: nextOpeningOrClosingDate.timeSlot!,
        );
      }
      _updateLoadingState(event.locationId, nextOpeningDate: LoadingState.loaded);
      emit(_createLoadedState());
      debugPrint(
          '✅ [ScheduleBloc] Next opening date: ${_nextOpeningOrClosingDates[event.locationId]} for promoter ${event.locationId} from ${event.fromDate}');
    } catch (e) {
      debugPrint('❌ [ScheduleBloc] Error getting next opening date for promoter ${event.locationId} from ${event.fromDate}: $e');
      _updateLoadingState(event.locationId, nextOpeningDate: LoadingState.error);
      emit(_createLoadedState());
    }
  }

  void _updateLoadingState(
    String locationId, {
    LoadingState? isOpen,
    LoadingState? monthSchedule,
    LoadingState? nextOpeningDate,
  }) {
    final ScheduleLoadingState current = _loadingStates[locationId] ??
        ScheduleLoadingState(
          isOpen: LoadingState.initial,
          monthSchedule: LoadingState.initial,
          nextOpeningDate: LoadingState.initial,
        );
    _loadingStates[locationId] = current.copyWith(
      isOpen: isOpen,
      monthSchedule: monthSchedule,
      nextOpeningDate: nextOpeningDate,
    );
  }

  ScheduleLoaded _createLoadedState() {
    return ScheduleLoaded(
      loadingStates: _loadingStates,
      monthSchedules: _monthSchedules,
      next30DaysSchedules: _next30DaysSchedules,
      nextOpeningOrClosingDates: _nextOpeningOrClosingDates,
      isOpen: _isOpen,
    );
  }

  Future<List<DaySchedule>> _buildNext30DaysSchedule(
    DateTime fromDate,
    LocationSchedule regularSchedule,
    List<SpecialDaySchedule> specialSchedules,
  ) async {
    final List<DaySchedule> monthSchedule = [];
    final DateTime startOfSchedule = fromDate;
    final DateTime endOfSchedule = fromDate.add(const Duration(days: 30));
    debugPrint('🔍 [ScheduleBloc] Building schedule from $startOfSchedule to $endOfSchedule');
    DateTime currentCheck = startOfSchedule;
    while (currentCheck.isBefore(endOfSchedule)) {
      final weekday = currentCheck.weekday;
      final RegularDaySchedule? regularDay = regularSchedule.weekSchedule[weekday];
      if (regularDay == null || !regularDay.isOpen) {
        currentCheck = currentCheck.add(const Duration(days: 1));
        continue;
      }
      debugPrint('➕ [ScheduleBloc] Adding regular day to calendar: $regularDay');
      final DateTime newTimeSlotStart = DateTime(
        currentCheck.year,
        currentCheck.month,
        currentCheck.day,
      ).add(
        Duration(
          hours: regularDay.timeSlot!.startDateTime.hour,
          minutes: regularDay.timeSlot!.startDateTime.minute,
        ),
      );
      final int dayDuration = regularDay.timeSlot!.endDateTime.difference(regularDay.timeSlot!.startDateTime).inMinutes;

      final DateTime newTimeSlotEnd = newTimeSlotStart.add(Duration(minutes: dayDuration));

      final TimeSlot newTimeSlot = TimeSlot(
        startDateTime: newTimeSlotStart,
        endDateTime: newTimeSlotEnd,
      );
      monthSchedule.add(regularDay.copyWith(timeSlot: newTimeSlot));
      currentCheck = currentCheck.add(const Duration(days: 1));
    }
    for (final SpecialDaySchedule specialSchedule in specialSchedules) {
      if (monthSchedule.any((element) => element.timeSlot == specialSchedule.overriddenRegularSlot)) {
        monthSchedule.removeWhere((element) => element.timeSlot == specialSchedule.overriddenRegularSlot);
        monthSchedule.add(specialSchedule);
      } else {
        monthSchedule.add(specialSchedule);
      }
    }

    // Sort the schedule by effective start time
    monthSchedule.sort((a, b) {
      DateTime? getEffectiveStart(DaySchedule schedule) {
        if (schedule is SpecialDaySchedule) {
          return schedule.overriddenRegularSlot?.startDateTime ?? schedule.timeSlot?.startDateTime;
        }
        return (schedule as RegularDaySchedule).timeSlot?.startDateTime;
      }

      final aStart = getEffectiveStart(a);
      final bStart = getEffectiveStart(b);

      // Handle nulls by putting them at the end
      if (aStart == null && bStart == null) return 0;
      if (aStart == null) return 1;
      if (bStart == null) return -1;

      return aStart.compareTo(bStart);
    });

    debugPrint('🔍 [ScheduleBloc] Sorted schedule: $monthSchedule');
    return monthSchedule;
  }
}
