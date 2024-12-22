import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livit/cloud_models/location/location_media.dart';

class Location {
  final String id;
  final String name;
  final String address;
  final GeoPoint? geopoint;
  final String department;
  final String city;
  final String? description;
  final LivitLocationMedia? media;

  Location(
      {required this.id,
      required this.name,
      required this.address,
      required this.geopoint,
      required this.department,
      required this.city,
      this.description,
      this.media});

  Location.empty()
      : id = DateTime.now().millisecondsSinceEpoch.toString(),
        name = '',
        address = '',
        geopoint = null,
        department = '',
        city = '',
        description = null,
        media = null;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'geopoint': geopoint,
      'department': department,
      'city': city,
      'media': media?.toMap(),
      'description': description,
    };
  }

  Location copyWith(
      {String? id,
      String? name,
      String? address,
      GeoPoint? geopoint,
      String? department,
      String? city,
      String? description,
      LivitLocationMedia? media}) {
    return Location(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      geopoint: geopoint ?? this.geopoint,
      department: department ?? this.department,
      city: city ?? this.city,
      description: description ?? this.description,
      media: media ?? this.media,
    );
  }

  factory Location.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Location(
      id: doc.id,
      name: data['name'] as String,
      address: data['address'] as String,
      geopoint: data['geopoint'] as GeoPoint?,
      department: data['department'] as String,
      city: data['city'] as String,
      description: data['description'] as String?,
      media: data['media'] != null ? LivitLocationMedia.fromMap(data['media'] as Map<String, dynamic>) : null,
    );
  }

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      id: map['id'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      geopoint: map['geopoint'] as GeoPoint?,
      department: map['department'] as String,
      city: map['city'] as String,
      description: map['description'] as String?,
      media: map['media'] != null ? LivitLocationMedia.fromMap(map['media'] as Map<String, dynamic>) : null,
    );
  }

  @override
  String toString() {
    return 'Location(name: $name, address: $address, geopoint: $geopoint, department: $department, city: $city, description: $description, media: $media)';
  }
}
