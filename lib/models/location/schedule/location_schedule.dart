import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

part 'day_schedule.dart';
part 'time_slot.dart';

class LocationSchedule {
  final Map<int, RegularDaySchedule> weekSchedule;

  LocationSchedule({
    required this.weekSchedule,
  });

  Map<String, dynamic> toMap() {
    return {
      'weekSchedule': weekSchedule.map(
        (key, value) => MapEntry(
          key.toString(),
          value.toMap(),
        ),
      ),
    };
  }

  factory LocationSchedule.fromMap(Map<String, dynamic> map) {
    debugPrint('🔍 [LocationSchedule] Creating location schedule from map: $map');
    return LocationSchedule(
      weekSchedule: map.map(
        (key, value) => MapEntry(
          int.parse(key),
          RegularDaySchedule.fromMap(value as Map<String, dynamic>),
        ),
      ),
    );
  }

  Future<bool> isNormallyOpenOn(DateTime date) async {
    final daySchedule = weekSchedule[date.weekday];
    if (daySchedule == null || !daySchedule.isOpen) return false;
    return isTimeInSlots(date, daySchedule.timeSlot);
  }

  bool isTimeInSlots(DateTime dateTime, TimeSlot? slot) {
    if (slot == null) return false;
    return slot.startDateTime.compareTo(dateTime) <= 0 && slot.endDateTime.compareTo(dateTime) > 0;
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }
}
