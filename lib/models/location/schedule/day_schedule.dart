part of 'location_schedule.dart';

abstract class DaySchedule {
  final bool isOpen;
  final TimeSlot? timeSlot;

  DaySchedule({
    required this.isOpen,
    required this.timeSlot,
  });

  Map<String, dynamic> toMap();
}

class RegularDaySchedule extends DaySchedule {
  RegularDaySchedule({
    required super.isOpen,
    required super.timeSlot,
  }) : assert(isOpen && timeSlot != null || !isOpen && timeSlot == null, 'Regular day schedule must be open and have a time slot');

  factory RegularDaySchedule.closed() {
    return RegularDaySchedule(isOpen: false, timeSlot: null);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'isOpen': isOpen,
      'timeSlot': timeSlot?.toMap(),
    };
  }

  factory RegularDaySchedule.fromMap(Map<String, dynamic> map) {
    return RegularDaySchedule(
      isOpen: map['isOpen'],
      timeSlot: map['timeSlot'] != null ? TimeSlot.fromMap(map['timeSlot']) : null,
    );
  }

  RegularDaySchedule copyWith({bool? isOpen, TimeSlot? timeSlot}) {
    return RegularDaySchedule(isOpen: isOpen ?? this.isOpen, timeSlot: timeSlot ?? this.timeSlot);
  }

  @override
  String toString() {
    return 'RegularDaySchedule(isOpen: $isOpen, timeSlot: $timeSlot)';
  }
}

class SpecialDaySchedule extends DaySchedule {
  final String? note;
  final TimeSlot? overriddenRegularSlot;

  SpecialDaySchedule({
    required super.isOpen,
    required super.timeSlot,
    this.note,
    this.overriddenRegularSlot,
  });

  factory SpecialDaySchedule.closed({TimeSlot? overriddenRegularSlot}) {
    return SpecialDaySchedule(isOpen: false, timeSlot: null, overriddenRegularSlot: overriddenRegularSlot);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'isOpen': isOpen,
      'timeSlot': timeSlot?.toMap(),
      'note': note,
      'overriddenRegularSlot': overriddenRegularSlot?.toMap(),
    };
  }

  factory SpecialDaySchedule.fromDocument(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data() ?? {};
    return SpecialDaySchedule(
      isOpen: data['isOpen'] ?? false,
      timeSlot: data['timeSlot'] != null ? TimeSlot.fromMap(data['timeSlot'] as Map<String, dynamic>) : null,
      note: data['note'],
      overriddenRegularSlot:
          data['overriddenRegularSlot'] != null ? TimeSlot.fromMap(data['overriddenRegularSlot'] as Map<String, dynamic>) : null,
    );
  }

  SpecialDaySchedule copyWith({
    bool? isOpen,
    TimeSlot? timeSlot,
    String? note,
    TimeSlot? overriddenRegularSlot,
  }) {
    return SpecialDaySchedule(
      isOpen: isOpen ?? this.isOpen,
      timeSlot: timeSlot ?? this.timeSlot,
      note: note ?? this.note,
      overriddenRegularSlot: overriddenRegularSlot ?? this.overriddenRegularSlot,
    );
  }

  @override
  String toString() {
    return 'SpecialDaySchedule(isOpen: $isOpen, timeSlot: $timeSlot, note: $note, overriddenRegularSlot: $overriddenRegularSlot)';
  }
}
