import 'dart:io';
import 'package:livit/cloud_models/location/location.dart';

abstract class LocationEvent {
  const LocationEvent();
}

class InitializeLocationBloc extends LocationEvent {
  final String userId;
  const InitializeLocationBloc({required this.userId});
}

class LoadUserLocations extends LocationEvent {
  
  const LoadUserLocations();
}

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

class CreateLocations extends LocationEvent {
  final List<Location> locations;

  const CreateLocations({required this.locations});
}

class UpdateLocation extends LocationEvent {
  final Location location;

  const UpdateLocation({required this.location});
}

class UpdateLocations extends LocationEvent {
  final List<Location> locations;

  const UpdateLocations({required this.locations});
}

class DeleteLocation extends LocationEvent {
  final Location location;

  const DeleteLocation({required this.location});
}
