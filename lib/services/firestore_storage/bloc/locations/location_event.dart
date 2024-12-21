import 'package:livit/cloud_models/location/location.dart';
import 'package:livit/cloud_models/location/location_media.dart';

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

  const UpdateLocationMedia({
    required this.location,
  });
}

class UpdateLocationsMedia extends LocationEvent {
  final List<Location> locations;


  const UpdateLocationsMedia({
    required this.locations,
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
