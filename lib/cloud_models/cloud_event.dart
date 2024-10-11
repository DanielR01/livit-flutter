import 'package:cloud_firestore/cloud_firestore.dart';

class CloudEvent {
  final String eventId;
  final String description;
  final List<Map<String, dynamic>> dates;
  final List<Map<String, dynamic>> artists;
  final List<Map<String, dynamic>> locations;
  final Map<String, List<String>> media;
  final List<String> promoters;
  final List<String> tagsOfInterest;
  final List<TicketType> ticketTypes;
  final String state;

  CloudEvent({  
    required this.eventId,
    required this.description,
    required this.dates,
    required this.artists,
    required this.locations,
    required this.media,
    required this.promoters,
    required this.tagsOfInterest,
    required this.ticketTypes,
    required this.state,
  });

  CloudEvent copyWith({
    String? eventId,
    String? description,
    List<Map<String, dynamic>>? dates,
    List<Map<String, dynamic>>? artists,
    List<Map<String, dynamic>>? locations,
    Map<String, List<String>>? media,
    List<String>? promoters,
    List<String>? tagsOfInterest,
    List<TicketType>? ticketTypes,
    String? state,
  }){
    return CloudEvent(
      eventId:this.eventId,
      description: description ?? this.description,
      dates: dates ?? this.dates,
      artists: artists ?? this.artists,
      locations: locations ?? this.locations,
      media: media ?? this.media,
      promoters: promoters ?? this.promoters,
      tagsOfInterest: tagsOfInterest ?? this.tagsOfInterest,
      ticketTypes: ticketTypes ?? this.ticketTypes,
      state: state ?? this.state,
    );
  }

  factory CloudEvent.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CloudEvent(
      eventId: data['eventId'],
      description: data['description'],
      dates: data['dates'],
      artists: data['artists'],
      locations: data['locations'],
      media: data['media'],
      promoters: data['promoters'],
      tagsOfInterest: data['tagsOfInterest'],
      ticketTypes: data['ticketTypes'].map((e) => TicketType.fromMap(e)).toList(),
      state: data['state'],
    );
  }

  Map<String, Object?> toMap() {
    return {
      'eventId': eventId,
      'description': description,
      'dates': dates,
      'artists': artists,
      'locations': locations,
      'media': media,
      'promoters': promoters,
      'tagsOfInterest': tagsOfInterest,
      'ticketTypes': ticketTypes.map((e) => e.toMap()).toList(),
      'state': state,
      };
  }

  @override
  String toString() {
    return 'CloudEvent(eventId: $eventId, description: $description, dates: $dates, artists: $artists, locations: $locations, media: $media, promoters: $promoters, tagsOfInterest: $tagsOfInterest, ticketTypes: $ticketTypes, state: $state)';
  }
}

class TicketType {
  final String name;
  final int availableQuantity;
  final int totalQuantity;
  final String dateName;
  final String description;
  final Map<String, dynamic> price;
  final Map<String, dynamic> entranceLocation;

  TicketType({
    required this.name,
    required this.availableQuantity,
    required this.totalQuantity,
    required this.dateName,
    required this.description,
    required this.price,
    required this.entranceLocation,
  });

  TicketType copyWith({
    String? name,
    int? availableQuantity,
    int? totalQuantity,
    String? dateName,
    String? description,
    Map<String, dynamic>? price,
    Map<String, dynamic>? entranceLocation,
  }) {
    return TicketType(
      name: name ?? this.name,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      dateName: dateName ?? this.dateName,
      description: description ?? this.description,
      price: price ?? this.price,
      entranceLocation: entranceLocation ?? this.entranceLocation,
    );
  }

  factory TicketType.fromMap(Map<String, dynamic> map) {
    return TicketType(
      name: map['name'],
      availableQuantity: map['availableQuantity'],
      totalQuantity: map['totalQuantity'],
      dateName: map['dateName'],
      description: map['description'],
      price: map['price'],
      entranceLocation: map['entranceLocation'],
    );
  }

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'availableQuantity': availableQuantity,
      'totalQuantity': totalQuantity,
      'dateName': dateName,
      'description': description,
      'price': price,
      'entranceLocation': entranceLocation,
    };
  }

  @override
  String toString() {
    return 'TicketType(name: $name, availableQuantity: $availableQuantity, totalQuantity: $totalQuantity, dateName: $dateName, description: $description, price: $price, entranceLocation: $entranceLocation)';
  }
}
