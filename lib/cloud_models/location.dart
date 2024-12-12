import 'package:cloud_firestore/cloud_firestore.dart';

class Location {
  final String name;
  final String address;
  final GeoPoint? geopoint;
  final String department;
  final String city;

  Location({required this.name, required this.address, required this.geopoint, required this.department, required this.city});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'geopoint': geopoint,
      'department': department,
      'city': city,
    };
  }

  Location copyWith({String? name, String? address, GeoPoint? geopoint, String? department, String? city}) {
    return Location(
      name: name ?? this.name,
      address: address ?? this.address,
      geopoint: geopoint ?? this.geopoint,
      department: department ?? this.department,
      city: city ?? this.city,
    );
  }

  factory Location.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Location(
      name: data['name'] as String,
      address: data['address'] as String,
      geopoint: data['geopoint'] as GeoPoint?,
      department: data['department'] as String,
      city: data['city'] as String,
    );
  }

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      name: map['name'] as String,
      address: map['address'] as String,
      geopoint: map['geopoint'] as GeoPoint?,
      department: map['department'] as String,
      city: map['city'] as String,
    );
  }

  @override
  String toString() {
    return 'Location(name: $name, address: $address, geopoint: $geopoint, department: $department, city: $city)';
  }
}
