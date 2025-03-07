import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:livit/models/location/schedule/location_schedule.dart';
import 'package:livit/services/firestore_storage/bloc/schedule/schedule_bloc.dart';
import 'package:livit/services/firestore_storage/firestore_storage/collections.dart';

class LocationScheduleService {
  static final LocationScheduleService _shared = LocationScheduleService._sharedInstance();
  LocationScheduleService._sharedInstance();
  factory LocationScheduleService() => _shared;

  final Collections _collections = Collections();

  Future<List<SpecialDaySchedule>> getMonthSpecialSchedules(String locationId, DateTime month) async {
    try {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0).add(const Duration(days: 1));

      final snapshot = await _collections
          .specialSchedulesCollection(locationId)
          .where('timeSlots.startDateTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .where('timeSlots.endDateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('❌ [LocationScheduleService] Error getting month special schedules: $e');
      rethrow;
    }
  }

    Future<List<SpecialDaySchedule>> getNext30DaysSpecialSchedules(String locationId, DateTime fromDate) async {
    try {
      debugPrint('📥 [LocationScheduleService] Getting next 30 days special schedules for $locationId from $fromDate');
      final startOfSchedule = fromDate;
      final endOfSchedule = fromDate.add(const Duration(days: 30));

      final snapshot = await _collections
          .specialSchedulesCollection(locationId)
          .where('overriddenRegularSlot.startDateTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfSchedule))
          .where('overriddenRegularSlot.endDateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfSchedule))
          .get();

      debugPrint('✅ [LocationScheduleService] Found ${snapshot.docs.length} special schedules.');
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('❌ [LocationScheduleService] Error getting month special schedules: $e');
      rethrow;
    }
  }

  Future<SpecialDaySchedule?> getSpecialScheduleByDateTime(String locationId, DateTime dateTime) async {
    try {
      final snapshot = await _collections
          .specialSchedulesCollection(locationId)
          .where('timeSlots.startDateTime', isLessThanOrEqualTo: Timestamp.fromDate(dateTime))
          .where('timeSlots.endDateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(dateTime))
          .get();

      for (final doc in snapshot.docs) {
        final schedule = doc.data();
        if (schedule.isOpen && schedule.timeSlot?.containsDateTime(dateTime) == true) {
          return schedule;
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ [LocationScheduleService] Error getting special schedule: $e');
      rethrow;
    }
  }



}
