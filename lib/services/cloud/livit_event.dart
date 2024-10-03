import 'package:cloud_firestore/cloud_firestore.dart';

class LivitEvent {
  final String id;
  final String name;
  final String description;
  final List<EventDate> dates;
  final List<Artist> artists;
  final List<EventLocation> locations;
  final Map<String, String> media;
  final List<String> promoters;
  final List<TicketType> ticketTypes;
  final List<String> attendees;

  LivitEvent({
    required this.id,
    required this.name,
    required this.description,
    required this.dates,
    required this.artists,
    required this.locations,
    required this.media,
    required this.promoters,
    required this.ticketTypes,
    required this.attendees,
  });

  factory LivitEvent.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return LivitEvent(
      id: data['eventId'],
      name: data['eventName'],
      description: data['description'] ?? '',
      dates: (data['dates'] as List<dynamic>).map((item) => EventDate.fromMap(item)).toList(),
      artists: (data['artists'] as List<dynamic>).map((item) => Artist.fromMap(item)).toList(),
      locations: (data['location'] as List<dynamic>).map((item) => EventLocation.fromMap(item)).toList(),
      media: Map<String, String>.from(data['media'] ?? {}),
      promoters: List<String>.from(data['promoters'] ?? []),
      ticketTypes: (data['ticketTypes'] as List<dynamic>).map((item) => TicketType.fromMap(item)).toList(),
      attendees: List<String>.from(data['attendees'] ?? []),
    );
  }

  // Convert Event object to Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'eventId': id,
      'eventName': name,
      'description': description,
      'dates': dates.map((date) => date.toMap()).toList(),
      'artists': artists.map((artist) => artist.toMap()).toList(),
      'location': locations.map((location) => location.toMap()).toList(),
      'media': media,
      'promoters': promoters,
      'ticketTypes': ticketTypes.map((type) => type.toMap()).toList(),
      'attendees': attendees,
    };
  }
}

// Define EventDate class for dates field
class EventDate {
  final String name;
  final DateTime startTime;
  final DateTime endTime;

  EventDate({
    required this.name,
    required this.startTime,
    required this.endTime,
  });

  factory EventDate.fromMap(Map<String, dynamic> data) {
    return EventDate(
      name: data['name'],
      startTime: DateTime.parse(data['startTime']),
      endTime: DateTime.parse(data['endTime']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };
  }
}

class Artist {
  final String name;
  final String dateOfAssistance;
  final DateTime startTime;
  final DateTime endTime;
  final String description;
  final String? userReference;

  Artist({
    required this.name,
    required this.dateOfAssistance,
    required this.startTime,
    required this.endTime,
    required this.description,
    this.userReference,
  });

  factory Artist.fromMap(Map<String, dynamic> data) {
    return Artist(
      name: data['name'],
      dateOfAssistance: data['dateOfAssistance'],
      startTime: DateTime.parse(data['startTime']),
      endTime: DateTime.parse(data['endTime']),
      description: data['description'],
      userReference: data['userReference'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dateOfAssistance': dateOfAssistance,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'description': description,
      'userReference': userReference,
    };
  }
}

class EventLocation {
  final GeoPoint geopoint;
  final String name;
  final String date;

  EventLocation({
    required this.geopoint,
    required this.name,
    required this.date,
  });

  factory EventLocation.fromMap(Map<String, dynamic> data) {
    return EventLocation(
      geopoint: data['geopoint'],
      name: data['name'],
      date: data['date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'geopoint': geopoint,
      'name': name,
      'date': date,
    };
  }
}

class TicketType {
  final String name;
  final int availableQuantity;
  final int totalQuantity;
  final String dateName;
  final String description;
  final double price;

  TicketType({
    required this.name,
    required this.availableQuantity,
    required this.totalQuantity,
    required this.dateName,
    required this.description,
    required this.price,
  });

  factory TicketType.fromMap(Map<String, dynamic> data) {
    return TicketType(
      name: data['name'],
      availableQuantity: data['availableQuantity'],
      totalQuantity: data['totalQuantity'],
      dateName: data['dateName'],
      description: data['description'],
      price: data['price'].toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'availableQuantity': availableQuantity,
      'totalQuantity': totalQuantity,
      'dateName': dateName,
      'description': description,
      'price': price,
    };
  }
}
