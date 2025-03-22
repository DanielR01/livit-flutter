import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:livit/models/event/event_media.dart';
import 'package:livit/models/price/price.dart';

class LivitEvent {
  final String id;
  final String name;
  final String description;
  final List<EventDate> dates;
  final List<Artist?> artists;
  final List<EventLocation> locations;
  final EventMedia media;
  final List<String> promoters;
  final List<EventTicketType> eventTicketTypes;
  final Timestamp startTime;
  final Timestamp endTime;

  LivitEvent({
    required this.id,
    required this.name,
    required this.description,
    required this.dates,
    required this.artists,
    required this.locations,
    required this.media,
    required this.promoters,
    required this.eventTicketTypes,
    required this.startTime,
    required this.endTime,
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
      promoters: [],
      eventTicketTypes: [],
      startTime: Timestamp.now(),
      endTime: Timestamp.now(),
    );
  }

  factory LivitEvent.fromDocument(DocumentSnapshot doc) {
    debugPrint('🛠️ [LivitEvent] fromDocument: $doc');
    final data = doc.data() as Map<String, dynamic>;

    return LivitEvent(
      id: doc.id,
      name: data['name'],
      description: data['description'] ?? '',
      dates: (data['dates'] as List<dynamic>).map((item) => EventDate.fromMap(item)).toList(),
      artists: (data['artists'] as List<dynamic>).map((item) => item != null ? Artist.fromMap(item) : null).toList(),
      locations: (data['locations'] as List<dynamic>).map((item) => EventLocation.fromMap(item)).toList(),
      media: EventMedia.fromMap(data['media']),
      promoters: List<String>.from(data['promoters'] ?? []),
      eventTicketTypes: (data['ticketTypes'] as List<dynamic>).map((item) => EventTicketType.fromMap(item)).toList(),
      startTime: data['startTime'],
      endTime: data['endTime'],
    );
  }

  // Convert Event object to Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'eventId': id,
      'eventName': name,
      'description': description,
      'dates': dates.map((date) => date.toMap()).toList(),
      'artists': artists.map((artist) => artist?.toMap() ?? {}).toList(),
      'locations': locations.map((location) => location.toMap()).toList(),
      'media': media,
      'promoters': promoters,
      'ticketTypes': eventTicketTypes.map((type) => type.toMap()).toList(),
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  String toDateString() {
    final startDate = startTime.toDate();
    final endDate = endTime.toDate();
    return '${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}';
  }

  @override
  String toString() {
    return 'LivitEvent(id: $id, name: $name, description: $description, dates: $dates, artists: $artists, locations: $locations, media: $media, promoters: $promoters, eventTicketTypes: $eventTicketTypes, startTime: $startTime, endTime: $endTime)';
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
    debugPrint('🛠️ [EventDate] fromMap: $data');
    return EventDate(
      name: data['name'],
      startTime: data['startTime'],
      endTime: data['endTime'] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  @override
  String toString() {
    return 'EventDate(name: $name, startTime: $startTime, endTime: $endTime)';
  }
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
    debugPrint('🛠️ [Artist] fromMap: $data');
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
    debugPrint('🛠️ [EventLocation] fromMap: $data');
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
      'geopoint': geopoint,
      'name': name,
      'locationId': locationId,
      'dateName': dateName,
      'address': address,
      'city': city,
      'state': state,
      'description': description,
    };
  }
}

class EventTicketType {
  final String name;
  final int totalQuantity;
  final String dateName;
  final String description;
  final LivitPrice price;

  EventTicketType({
    required this.name,
    required this.totalQuantity,
    required this.dateName,
    required this.description,
    required this.price,
  });

  factory EventTicketType.empty() {
    return EventTicketType(
      name: '',
      totalQuantity: 0,
      dateName: '',
      description: '',
      price: LivitPrice.empty(),
    );
  }

  factory EventTicketType.fromMap(Map<String, dynamic> data) {
    debugPrint('🛠️ [EventTicketType] fromMap: $data');
    final int totalQuantity = (data['totalQuantity'] is int) ? data['totalQuantity'] : (data['totalQuantity'] as double).toInt();
    return EventTicketType(
      name: data['name'],
      totalQuantity: totalQuantity,
      dateName: data['dateName'],
      description: data['description'],
      price: LivitPrice.fromMap(data['price']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'totalQuantity': totalQuantity,
      'dateName': dateName,
      'description': description,
      'price': price.toMap(),
    };
  }

  @override
  String toString() {
    return 'EventTicketType(name: $name, totalQuantity: $totalQuantity, dateName: $dateName, description: $description, price: $price)';
  }
}
