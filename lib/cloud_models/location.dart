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

  @override
  String toString() {
    return 'Location(name: $name, address: $address, geopoint: $geopoint, department: $department, city: $city)';
  }
}

class Locations {
  final List<Location> locations;
  final bool isCompleted;

  Locations({required this.locations, required this.isCompleted});

  @override
  String toString() {
    return 'Locations(locations: $locations, isCompleted: $isCompleted)';
  }

  Locations copyWith({List<Location>? locations, bool? isCompleted}) {
    return Locations(
      locations: locations ?? this.locations,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'locations': locations.map((location) => location.toMap()).toList(),
      'isCompleted': isCompleted,
    };
  }

  factory Locations.fromMap(Map<String, dynamic> data) {
    return Locations(
      locations: (data['locations'] as List<dynamic>).cast<Location>(),
      isCompleted: data['isCompleted'] as bool,
    );
  }
}
