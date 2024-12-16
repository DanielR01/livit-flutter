import 'dart:io';
import 'package:livit/cloud_models/location.dart';

abstract class LocationEvent {
  const LocationEvent();
}

class LoadUserLocations extends LocationEvent {}

class UpdateLocationMedia extends LocationEvent {
  final Location location;
  final List<File> images;

  const UpdateLocationMedia({
    required this.location,
    required this.images,
  });
}

class CreateLocation extends LocationEvent {
  final Location location;

  const CreateLocation({required this.location});
}

class UpdateLocation extends LocationEvent {
  final Location location;

  const UpdateLocation({required this.location});
}

class DeleteLocation extends LocationEvent {
  final Location location;

  const DeleteLocation({required this.location});
}
