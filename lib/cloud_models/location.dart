import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livit/services/firebase_storage/storage_service.dart';
import 'package:livit/services/firebase_storage/bloc/storage_bloc.dart';
import 'package:livit/services/firebase_storage/bloc/storage_event.dart';
import 'package:livit/services/firebase_storage/bloc/storage_state.dart';
import 'dart:async';

class Location {
  final String id;
  final String name;
  final String address;
  final GeoPoint? geopoint;
  final String department;
  final String city;
  final String? description;
  final LocationMedia? media;

  Location(
      {required this.id,
      required this.name,
      required this.address,
      required this.geopoint,
      required this.department,
      required this.city,
      this.description,
      this.media});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
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
      {String? id, String? name, String? address, GeoPoint? geopoint, String? department, String? city, String? description, LocationMedia? media}) {
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
      media: data['media'] != null ? LocationMedia.fromMap(data['media'] as Map<String, dynamic>) : null,
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
      media: map['media'] != null ? LocationMedia.fromMap(map['media'] as Map<String, dynamic>) : null,
    );
  }

  Future<Location> addMedia({required List<File> images}) async {
    final storageBloc = StorageBloc(storageService: StorageService());

    final completer = Completer<List<String>>();

    late StreamSubscription<StorageState> subscription;

    subscription = storageBloc.stream.listen(
      (state) {
        if (state is StorageSuccess) {
          completer.complete(state.urls);
          subscription.cancel();
        } else if (state is StorageFailure) {
          completer.completeError(state.exception);
          subscription.cancel();
        }
      },
    );

    storageBloc.add(UploadLocationMedia(
      locationId: id,
      files: images,
      type: 'images',
    ));

    final urls = await completer.future;

    final LocationMedia newMedia = LocationMedia(
      mainUrl: urls.first,
      secondaryUrls: urls.length > 1 ? urls.sublist(1) : [],
    );

    return copyWith(media: newMedia);
  }

  @override
  String toString() {
    return 'Location(name: $name, address: $address, geopoint: $geopoint, department: $department, city: $city, description: $description, media: $media)';
  }
}

class LocationMedia {
  final String? mainUrl;
  final List<String?>? secondaryUrls;

  LocationMedia({this.mainUrl, this.secondaryUrls});

  Map<String, dynamic> toMap() {
    return {
      'mainUrl': mainUrl,
      'secondaryUrls': secondaryUrls,
    };
  }

  factory LocationMedia.fromMap(Map<String, dynamic> map) {
    return LocationMedia(
      mainUrl: map['mainUrl'] as String?,
      secondaryUrls: map['secondaryUrls'] as List<String?>?,
    );
  }
}
