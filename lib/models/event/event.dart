import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livit/models/event/event_media.dart';
import 'package:livit/models/price/price.dart';
import 'package:livit/utilities/debug/livit_debugger.dart';

const _debugger = LivitDebugger('event_model');

class LivitEvent {
  final String id;
  final String name;
  final String description;
  final List<EventDate> dates;
  final List<Artist?> artists;
  final List<EventLocation> locations;
  final EventMedia media;
  final List<String> promoterIds;
  final List<EventTicketType> eventTicketTypes;
  final Timestamp startTime;
  final Timestamp endTime;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  LivitEvent({
    required this.id,
    required this.name,
    required this.description,
    required this.dates,
    required this.artists,
    required this.locations,
    required this.media,
    required this.promoterIds,
    required this.eventTicketTypes,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LivitEvent.empty() {
    return LivitEvent(
      id: '',
      name: '',
      description: '',
      dates: [],
      artists: [],
      locations: [],
      media: EventMedia(media: []),
      promoterIds: [],
      eventTicketTypes: [],
      startTime: Timestamp.now(),
      endTime: Timestamp.now(),
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );
  }

  factory LivitEvent.fromMap(Map<String, dynamic> data) {
    _debugger.debPrint('fromMap: $data', DebugMessageType.reading);
    return LivitEvent(
      id: data['id'],
      name: data['name'],
      description: data['description'],
      dates: (data['dates'] as List<dynamic>).map((item) => EventDate.fromMap(item)).toList(),
      artists: (data['artists'] as List<dynamic>).map((item) => item != null ? Artist.fromMap(item) : null).toList(),
      locations: (data['locations'] as List<dynamic>).map((item) => EventLocation.fromMap(item)).toList(),
      media: EventMedia.fromMap(data['media']),
      promoterIds: List<String>.from(data['promoterIds'] ?? []),
      eventTicketTypes: (data['ticketTypes'] as List<dynamic>).map((item) => EventTicketType.fromMap(item)).toList(),
      startTime: data['startTime'],
      endTime: data['endTime'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }

  factory LivitEvent.fromDocument(DocumentSnapshot doc) {
    _debugger.debPrint('fromDocument: $doc', DebugMessageType.reading);
    final data = doc.data() as Map<String, dynamic>;

    return LivitEvent(
      id: doc.id,
      name: data['name'],
      description: data['description'] ?? '',
      dates: (data['dates'] as List<dynamic>).map((item) => EventDate.fromMap(item)).toList(),
      artists: (data['artists'] as List<dynamic>).map((item) => item != null ? Artist.fromMap(item) : null).toList(),
      locations: (data['locations'] as List<dynamic>).map((item) => EventLocation.fromMap(item)).toList(),
      media: EventMedia.fromMap(data['media']),
      promoterIds: List<String>.from(data['promoterIds'] ?? []),
      eventTicketTypes: (data['ticketTypes'] as List<dynamic>).map((item) => EventTicketType.fromMap(item)).toList(),
      startTime: data['startTime'],
      endTime: data['endTime'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }

  // Convert Event object to Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'dates': dates.map((date) => date.toMap()).toList(),
      'artists': [],
      'locations': locations.map((location) => location.toMap()).toList(),
      'tickets': eventTicketTypes.map((ticket) => ticket.toMap()).toList(),
      'promoterIds': promoterIds,
    };
  }

  LivitEvent copyWith({List<String>? promoterIds, String? id}) {
    return LivitEvent(
      id: id ?? this.id,
      name: name,
      description: description,
      dates: dates,
      artists: artists,
      locations: locations,
      media: media,
      promoterIds: promoterIds ?? this.promoterIds,
      eventTicketTypes: eventTicketTypes,
      startTime: startTime,
      endTime: endTime,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  String toDateString() {
    final startDate = startTime.toDate();
    final endDate = endTime.toDate();
    return '${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}';
  }

  @override
  String toString() {
    return 'LivitEvent(id: $id, name: $name, description: $description, dates: $dates, artists: $artists, locations: $locations, media: $media, promoters: $promoterIds, eventTicketTypes: $eventTicketTypes, startTime: $startTime, endTime: $endTime, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

class EventDate {
  final String name;
  final Timestamp startTime;
  final Timestamp endTime;

  EventDate({
    required this.name,
    required this.startTime,
    required this.endTime,
  });

  factory EventDate.fromMap(Map<String, dynamic> data) {
    _debugger.debPrint('fromMap: $data', DebugMessageType.reading);
    return EventDate(
      name: data['name'],
      startTime: data['startTime'],
      endTime: data['endTime'] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'startTime': serializeTimestamp(startTime),
      'endTime': serializeTimestamp(endTime),
    };
  }

  @override
  String toString() {
    return 'EventDate(name: $name, startTime: $startTime, endTime: $endTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventDate &&
        other.name == name &&
        other.startTime.seconds == startTime.seconds &&
        other.startTime.nanoseconds == startTime.nanoseconds &&
        other.endTime.seconds == endTime.seconds &&
        other.endTime.nanoseconds == endTime.nanoseconds;
  }

  @override
  int get hashCode =>
      name.hashCode ^ startTime.seconds.hashCode ^ startTime.nanoseconds.hashCode ^ endTime.seconds.hashCode ^ endTime.nanoseconds.hashCode;
}

class Artist {
  final String name;
  final String dateOfAssistanceName;
  final Timestamp startTime;
  final Timestamp endTime;
  final String description;
  final String? userId;

  Artist({
    required this.name,
    required this.dateOfAssistanceName,
    required this.startTime,
    required this.endTime,
    required this.description,
    this.userId,
  });

  factory Artist.fromMap(Map<String, dynamic> data) {
    _debugger.debPrint('fromMap: $data', DebugMessageType.reading);
    return Artist(
      name: data['name'],
      dateOfAssistanceName: data['dateOfAssistanceName'],
      startTime: data['startTime'],
      endTime: data['endTime'],
      description: data['description'],
      userId: data['userId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dateOfAssistanceName': dateOfAssistanceName,
      'startTime': startTime,
      'endTime': endTime,
      'description': description,
      'userId': userId,
    };
  }
}

class EventLocation {
  final GeoPoint? geopoint;
  final String? name;
  final String? locationId;
  final String dateName;
  final String? address;
  final String? city;
  final String? state;
  final String? description;

  EventLocation({
    required this.geopoint,
    required this.name,
    required this.locationId,
    required this.dateName,
    this.address,
    this.city,
    this.state,
    this.description,
  });

  factory EventLocation.fromMap(Map<String, dynamic> data) {
    _debugger.debPrint('fromMap: $data', DebugMessageType.reading);
    return EventLocation(
      geopoint: data['geopoint'],
      name: data['name'],
      locationId: data['locationId'],
      dateName: data['dateName'],
      address: data['address'],
      city: data['city'],
      state: data['state'],
      description: data['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'geopoint': geopoint != null ? {'latitude': geopoint!.latitude, 'longitude': geopoint!.longitude} : null,
      'name': name,
      'locationId': locationId,
      'dateName': dateName,
      'address': address,
      'city': city,
      'state': state,
      'description': description
    };
  }
}

class EventTicketType {
  final String? name;
  final int? totalQuantity;
  final List<EventDateTimeSlot> validTimeSlots;
  final String? description;
  final LivitPrice price;

  EventTicketType({
    required this.name,
    required this.totalQuantity,
    required this.validTimeSlots,
    required this.description,
    required this.price,
  });

  factory EventTicketType.empty(
      {String? name, int? totalQuantity, List<EventDateTimeSlot>? validTimeSlots, String? description, LivitPrice? price}) {
    return EventTicketType(
      name: name,
      totalQuantity: totalQuantity,
      validTimeSlots: validTimeSlots?.map((slot) => slot.copyWith()).toList() ?? [],
      description: description,
      price: price ?? LivitPrice.empty(),
    );
  }

  factory EventTicketType.fromMap(Map<String, dynamic> data) {
    _debugger.debPrint('fromMap: $data', DebugMessageType.reading);
    final int totalQuantity = (data['totalQuantity'] is int) ? data['totalQuantity'] : (data['totalQuantity'] as double).toInt();
    return EventTicketType(
      name: data['name'],
      totalQuantity: totalQuantity,
      validTimeSlots: data['validTimeSlots'],
      description: data['description'],
      price: LivitPrice.fromMap(data['price']),
    );
  }

  EventTicketType copyWith(
      {String? name, int? totalQuantity, List<EventDateTimeSlot>? validTimeSlots, String? description, LivitPrice? price}) {
    return EventTicketType(
      name: name ?? this.name,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      validTimeSlots: validTimeSlots ?? this.validTimeSlots,
      description: description ?? this.description,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'totalQuantity': totalQuantity,
      'validTimeSlots': validTimeSlots.map((slot) => slot.toMap()).toList(),
      'description': description,
      'price': price.toMap()
    };
  }

  @override
  String toString() {
    return 'EventTicketType(name: $name, totalQuantity: $totalQuantity, validTimeSlots: $validTimeSlots, description: $description, price: $price)';
  }
}

class EventDateTimeSlot {
  final String dateName;
  final Timestamp startTime;
  final Timestamp endTime;

  EventDateTimeSlot({
    required this.dateName,
    required this.startTime,
    required this.endTime,
  });

  factory EventDateTimeSlot.fromMap(Map<String, dynamic> data) {
    return EventDateTimeSlot(
      dateName: data['dateName'],
      startTime: data['startTime'],
      endTime: data['endTime'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateName': dateName,
      'startTime': serializeTimestamp(startTime),
      'endTime': serializeTimestamp(endTime),
    };
  }

  EventDateTimeSlot copyWith({DateTime? startTime, DateTime? endTime}) {
    return EventDateTimeSlot(
      dateName: dateName,
      startTime: Timestamp.fromDate(startTime ?? this.startTime.toDate()),
      endTime: Timestamp.fromDate(endTime ?? this.endTime.toDate()),
    );
  }

  @override
  String toString() {
    return 'TimeSlot(dateName: $dateName, startTime: $startTime, endTime: $endTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventDateTimeSlot &&
        other.dateName == dateName &&
        other.startTime.seconds == startTime.seconds &&
        other.startTime.nanoseconds == startTime.nanoseconds &&
        other.endTime.seconds == endTime.seconds &&
        other.endTime.nanoseconds == endTime.nanoseconds;
  }

  @override
  int get hashCode =>
      dateName.hashCode ^
      startTime.seconds.hashCode ^
      startTime.nanoseconds.hashCode ^
      endTime.seconds.hashCode ^
      endTime.nanoseconds.hashCode;
}

Map<String, int> serializeTimestamp(Timestamp timestamp) {
  return {
    'seconds': timestamp.seconds,
    'nanoseconds': timestamp.nanoseconds,
  };
}
