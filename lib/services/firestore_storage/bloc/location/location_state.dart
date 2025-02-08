import 'package:livit/constants/enums.dart';
import 'package:livit/models/location/location.dart';
import 'package:livit/services/exceptions/base_exception.dart';

abstract class LocationState {
  const LocationState();
}

class LocationUninitialized extends LocationState {
  const LocationUninitialized();
}

class LocationsLoaded extends LocationState {
  final List<LivitLocation> cloudLocations;
  final List<LivitLocation> localSavedLocations;
  final List<LivitLocation> localUnsavedLocations;
  final Map<LivitLocation, Map<String, LivitException>>? failedLocations;
  final Map<String, LoadingState> loadingStates;
  final String? errorMessage;
  final Exception? exception;

  const LocationsLoaded(
      {required this.cloudLocations,
      required this.localSavedLocations,
      required this.localUnsavedLocations,
      this.failedLocations,
      this.errorMessage,
      this.loadingStates = const {},
      this.exception});
}
