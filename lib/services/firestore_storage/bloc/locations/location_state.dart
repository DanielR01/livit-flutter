import 'package:livit/cloud_models/location/location.dart';

abstract class LocationState {
  const LocationState();
}

class LocationUninitialized extends LocationState {
  const LocationUninitialized();
}

class LocationsLoaded extends LocationState {
  final List<Location> cloudLocations;
  final List<Location> localSavedLocations;
  final List<Location> localUnsavedLocations;
  final Map<Location, String>? failedLocations;
  final Map<String, LoadingState> loadingStates;
  final String? errorMessage;

  const LocationsLoaded(
      {required this.cloudLocations,
      required this.localSavedLocations,
      required this.localUnsavedLocations,
      this.failedLocations,
      this.errorMessage,
      this.loadingStates = const {
        
      }});
}

enum LoadingState {
  loading,
  loaded,
  error,
}