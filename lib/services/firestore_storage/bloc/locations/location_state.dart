import 'package:livit/cloud_models/location/location.dart';

abstract class LocationState {
  const LocationState();
}

class LocationUninitialized extends LocationState {
  const LocationUninitialized();
}

class LocationLoading extends LocationState {
  const LocationLoading();
}

class LocationsLoaded extends LocationState {
  final List<Location> locations;
  final Map<Location, String>? failedLocations;
  final bool isLoading;
  final String? errorMessage;

  const LocationsLoaded({required this.locations, this.failedLocations, this.errorMessage, this.isLoading = false});
}
