import 'package:livit/cloud_models/location/location.dart';
import 'package:livit/cloud_models/location/location_media.dart';

abstract class LocationEvent {
  const LocationEvent();
}

class InitializeLocationBloc extends LocationEvent {
  final String userId;
  const InitializeLocationBloc({required this.userId});
}

// Cloud Events

class GetUserLocations extends LocationEvent {
  const GetUserLocations();
}


class CreateLocationsToCloud extends LocationEvent {
  final List<Location> locations;

  const CreateLocationsToCloud({required this.locations});
}

class UpdateLocationToCloud extends LocationEvent {
  final Location location;

  const UpdateLocationToCloud({required this.location});
}

class UpdateLocationsToCloud extends LocationEvent {
  final List<Location> locations;

  const UpdateLocationsToCloud({required this.locations});
}

class UpdateLocationsToCloudFromLocal extends LocationEvent {
  const UpdateLocationsToCloudFromLocal();
}

class DeleteLocationToCloud extends LocationEvent {
  final Location location;

  const DeleteLocationToCloud({required this.location});
}

class UpdateLocationsMediaToCloud extends LocationEvent {
  final List<Location> locations;

  const UpdateLocationsMediaToCloud({required this.locations});
}

// Local Events

class CreateLocationLocally extends LocationEvent {
  final Location location;

  const CreateLocationLocally({required this.location});
}

class UpdateLocationLocally extends LocationEvent {
  final Location location;

  const UpdateLocationLocally({required this.location});
}

class DeleteLocationLocally extends LocationEvent {
  final Location location;

  const DeleteLocationLocally({required this.location});
}

class UpdateLocationMediaLocally extends LocationEvent {
  final Location location;
  final LivitLocationMedia media;

  const UpdateLocationMediaLocally({required this.location, required this.media});
}

class SaveChangesLocally extends LocationEvent {
  const SaveChangesLocally();
}
