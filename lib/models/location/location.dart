import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:livit/models/location/location_media.dart';
import 'package:livit/services/firestore_storage/firestore_storage/exceptions/locations_exceptions.dart';

class LivitLocation {
  final String id;
  final String userId;
  final String name;
  final String address;
  final GeoPoint? geopoint;
  final String state;
  final String city;
  final String? description;
  final LivitLocationMedia? media;
  final Timestamp? createdAt;

  LivitLocation(
      {required this.id,
      required this.userId,
      required this.name,
      required this.address,
      required this.geopoint,
      required this.state,
      required this.city,
      this.description,
      this.media,
      this.createdAt});

  LivitLocation.empty()
      : id = DateTime.now().millisecondsSinceEpoch.toString(),
        userId = '',
        name = '',
        address = '',
        geopoint = null,
        state = '',
        city = '',
        description = null,
        media = null,
        createdAt = null;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'userId': userId,
      'address': address,
      'geopoint': geopoint,
      'department': state,
      'city': city,
      'media': media?.toMap(),
      'description': description,
      'createdAt': createdAt,
    };
  }

  LivitLocation copyWith({
    String? id,
    String? userId,
    String? name,
    String? address,
    GeoPoint? geopoint,
    String? state,
    String? city,
    String? description,
    LivitLocationMedia? media,
    Timestamp? createdAt,
  }) {
    return LivitLocation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      address: address ?? this.address,
      geopoint: geopoint ?? this.geopoint,
      state: state ?? this.state,
      city: city ?? this.city,
      description: description ?? this.description,
      media: media ?? this.media,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  LivitLocation removeGeopoint() {
    return LivitLocation(
      id: id,
      userId: userId,
      name: name,
      address: address,
      geopoint: null,
      state: state,
      city: city,
      description: description,
      media: media,
      createdAt: createdAt,
    );
  }

  factory LivitLocation.fromDocument(DocumentSnapshot doc) {
    try {
      debugPrint('📦 [LivitLocation] Creating location from document');
      final data = doc.data() as Map<String, dynamic>;
      debugPrint('📦 [LivitLocation] Data: $data');
      final LivitLocation location = LivitLocation(
        id: doc.id,
        userId: data['userId'] as String,
        name: data['name'] as String,
        address: data['address'] as String,
        geopoint: data['geopoint'] as GeoPoint?,
        state: data['state'] as String,
        city: data['city'] as String,
        description: data['description'] as String?,
        media: data['media'] != null ? LivitLocationMedia.fromMap(data['media'] as Map<String, dynamic>) : null,
        createdAt: data['createdAt'] as Timestamp?,
      );
      debugPrint('📥 [LivitLocation] Location created from document: ${location.name}');
      return location;
    } catch (e) {
      debugPrint('❌ [LivitLocation] Failed to create location from document: $e');
      throw CouldNotCreateLocationFromDocumentException(details: e.toString());
    }
  }

  factory LivitLocation.fromMap(Map<String, dynamic> map) {
    // Parse the date string into a DateTime
    Timestamp? createdAt;
    if (map['createdAt'] != null) {
      final parts = (map['createdAt'] as String).split(', ');
      final dateParts = parts[0].split('/');
      final timeParts = parts[1].split(':');

      final dateTime = DateTime.utc(
        int.parse(dateParts[2]), // year
        int.parse(dateParts[1]), // month
        int.parse(dateParts[0]), // day
        int.parse(timeParts[0]), // hour
        int.parse(timeParts[1]), // minute
        int.parse(timeParts[2]), // second
      );

      createdAt = Timestamp.fromDate(dateTime);
    }

    return LivitLocation(
      id: map['id'] as String,
      userId: map['userId'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      geopoint: map['geopoint'] as GeoPoint?,
      state: map['department'] as String,
      city: map['city'] as String,
      description: map['description'] as String?,
      media: map['media'] != null ? LivitLocationMedia.fromMap(map['media'] as Map<String, dynamic>) : null,
      createdAt: createdAt,
    );
  }

  @override
  String toString() {
    return 'Location(id: $id, name: $name, userId: $userId, address: $address, geopoint: $geopoint, department: $state, city: $city, description: $description, media: $media, createdAt: $createdAt)';
  }
}
