import 'package:flutter/material.dart';
import 'package:livit/cloud_models/location/location.dart';
import 'package:livit/cloud_models/location/location_media.dart';

abstract class LocationEvent {
  final BuildContext context;
  LocationEvent(this.context);
}

class InitializeLocationBloc extends LocationEvent {
  final String userId;
  InitializeLocationBloc(super.context, {required this.userId});
}

// Cloud Events

class GetUserLocations extends LocationEvent {
  GetUserLocations(super.context);
}

class CreateLocationsToCloud extends LocationEvent {
  final List<LivitLocation> locations;

  CreateLocationsToCloud(super.context, this.locations);
}

class CreateLocationsToCloudFromLocal extends LocationEvent {
  CreateLocationsToCloudFromLocal(super.context);
}

class UpdateLocationToCloud extends LocationEvent {
  final LivitLocation location;

  UpdateLocationToCloud(super.context, {required this.location});
}

class UpdateLocationsToCloud extends LocationEvent {
  final List<LivitLocation> locations;

  UpdateLocationsToCloud(super.context, {required this.locations});
}

class UpdateLocationsToCloudFromLocal extends LocationEvent {
  UpdateLocationsToCloudFromLocal(super.context);
}

class DeleteLocationToCloud extends LocationEvent {
  final LivitLocation location;

  DeleteLocationToCloud(super.context, {required this.location});
}

class UpdateLocationsMediaToCloud extends LocationEvent {
  final List<LivitLocation> locations;

  UpdateLocationsMediaToCloud(super.context, {required this.locations});
}

class UpdateLocationsMediaToCloudFromLocal extends LocationEvent {
  UpdateLocationsMediaToCloudFromLocal(super.context);
}

class SkipUpdateLocationsMediaToCloud extends LocationEvent {
  SkipUpdateLocationsMediaToCloud(super.context);
}

// Local Events

class CreateLocationLocally extends LocationEvent {
  final LivitLocation location;

  CreateLocationLocally(super.context, {required this.location});
}

class UpdateLocationLocally extends LocationEvent {
  final LivitLocation location;

  UpdateLocationLocally(super.context, {required this.location});
}

class DeleteLocationLocally extends LocationEvent {
  final LivitLocation location;

  DeleteLocationLocally(super.context, {required this.location});
}

class UpdateLocationMediaLocally extends LocationEvent {
  final LivitLocation location;
  final LivitLocationMedia media;

  UpdateLocationMediaLocally(super.context, {required this.location, required this.media});
}

class SaveChangesLocally extends LocationEvent {
  SaveChangesLocally(super.context);
}

class DiscardChangesLocally extends LocationEvent {
  DiscardChangesLocally(super.context);
}
