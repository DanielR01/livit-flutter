part of 'location_schedule.dart';

class TimeSlot {
  final DateTime startDateTime;
  final DateTime endDateTime;

  TimeSlot({
    required this.startDateTime,
    required this.endDateTime,
  }) : assert(endDateTime.isAfter(startDateTime), 'End time must be after start time');

  Map<String, dynamic> toMap() {
    return {
      'startDateTime': Timestamp.fromDate(DateTime(
        startDateTime.year,
        startDateTime.month,
        startDateTime.day,
        startDateTime.hour,
        startDateTime.minute,
      )),
      'endDateTime': Timestamp.fromDate(DateTime(
        endDateTime.year,
        endDateTime.month,
        endDateTime.day,
        endDateTime.hour,
        endDateTime.minute,
      )),
    };
  }

  factory TimeSlot.fromMap(Map<String, dynamic> map) {
    return TimeSlot(
      startDateTime: _parseTimestamp(map['startDateTime'] as Timestamp),
      endDateTime: _parseTimestamp(map['endDateTime'] as Timestamp),
    );
  }

  static DateTime _parseTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateTime(
      date.year,
      date.month,
      date.day,
      date.hour,
      date.minute,
    );
  }

  bool containsDateTime(DateTime dateTime) {
    return (dateTime.isAfter(startDateTime) || dateTime.isAtSameMomentAs(startDateTime)) && dateTime.isBefore(endDateTime);
  }

  bool overlapsWith(DateTime checkStart, DateTime checkEnd) {
    return startDateTime.isBefore(checkEnd) && endDateTime.isAfter(checkStart);
  }

  @override
  String toString() {
    return 'TimeSlot(startDateTime: $startDateTime, endDateTime: $endDateTime)';
  }

  @override
  bool operator ==(Object other) {
    if (other is! TimeSlot) return false;
    return startDateTime == other.startDateTime && endDateTime == other.endDateTime;
  }

  @override
  int get hashCode => startDateTime.hashCode ^ endDateTime.hashCode;
}
