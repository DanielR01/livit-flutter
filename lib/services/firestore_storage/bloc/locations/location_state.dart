import 'package:livit/cloud_models/location.dart';

abstract class LocationState {
  const LocationState();
}

class LocationInitial extends LocationState {
  const LocationInitial();
}

class LocationLoading extends LocationState {
  const LocationLoading();
}

class LocationsLoaded extends LocationState {
  final List<Location> locations;
  const LocationsLoaded({required this.locations});
}

class LocationError extends LocationState {
  final String message;
  const LocationError({required this.message});
}