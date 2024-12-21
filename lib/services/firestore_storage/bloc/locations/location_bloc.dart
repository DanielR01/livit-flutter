import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/cloud_models/location/location.dart';
import 'package:livit/services/firestore_storage/bloc/locations/location_event.dart';
import 'package:livit/services/firestore_storage/bloc/locations/location_state.dart';
import 'package:livit/services/firestore_storage/firestore_storage/firestore_storage.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final FirestoreStorage _cloudStorage;
  List<Location> _locations = [];
  String? _userId;

  LocationBloc()
      : _cloudStorage = FirestoreStorage(),
        super(const LocationUninitialized()) {
    on<InitializeLocationBloc>(_onInitializeLocationBloc);
    on<LoadUserLocations>(_onLoadUserLocations);
    on<CreateLocation>(_onCreateLocation);
    on<CreateLocations>(_onCreateLocations);
    on<UpdateLocation>(_onUpdateLocation);
    on<UpdateLocations>(_onUpdateLocations);
    on<DeleteLocation>(_onDeleteLocation);
    on<UpdateLocationsMedia>(_onUpdateLocationsMedia);
  }

  bool get isInitialized => _userId != null;

  void _ensureInitialized() {
    if (!isInitialized) {
      throw StateError('LocationBloc must be initialized with InitializeLocationBloc before using other events');
    }
  }

  Future<void> _onInitializeLocationBloc(
    InitializeLocationBloc event,
    Emitter<LocationState> emit,
  ) async {
    _userId = event.userId;
    add(LoadUserLocations());
  }

  Future<void> _onLoadUserLocations(
    LoadUserLocations event,
    Emitter<LocationState> emit,
  ) async {
    _ensureInitialized();

    emit(const LocationLoading());

    try {
      final locations = await _cloudStorage.locationMethods.getUserLocations(_userId!);
      emit(LocationsLoaded(locations: locations));
      _locations = locations;
    } catch (e) {
      emit(LocationsLoaded(locations: _locations, errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateLocationsMedia(
    UpdateLocationsMedia event,
    Emitter<LocationState> emit,
  ) async {
    _ensureInitialized();
    emit(LocationsLoaded(locations: _locations, isLoading: true));
    Map<Location, String>? failedLocations;
    try {
      for (var location in event.locations) {
        try {
          await _cloudStorage.locationMethods.updateLocation(_userId!, location);
        } catch (e) {
          failedLocations ??= {};
          failedLocations[location] = e.toString();
        }
      }
      final locations = await _cloudStorage.locationMethods.getUserLocations(_userId!);
      emit(LocationsLoaded(locations: locations, failedLocations: failedLocations));
      _locations = locations;
    } catch (e) {
      emit(LocationsLoaded(locations: _locations, errorMessage: e.toString()));
    }
  }

  Future<void> _onCreateLocations(
    CreateLocations event,
    Emitter<LocationState> emit,
  ) async {
    _ensureInitialized();
    emit(LocationsLoaded(locations: _locations, isLoading: true));
    Map<Location, String>? failedLocations;
    try {
      for (var location in event.locations) {
        try {
          await _cloudStorage.locationMethods.createLocation(_userId!, location);
        } catch (e) {
          failedLocations ??= {};
          failedLocations[location] = e.toString();
        }
      }
      final locations = await _cloudStorage.locationMethods.getUserLocations(_userId!);
      emit(LocationsLoaded(locations: locations, failedLocations: failedLocations));
      _locations = locations;
    } catch (e) {
      emit(LocationsLoaded(locations: _locations, errorMessage: e.toString()));
    }
  }

  Future<void> _onCreateLocation(
    CreateLocation event,
    Emitter<LocationState> emit,
  ) async {
    _ensureInitialized();
    emit(const LocationLoading());
  }

  Future<void> _onUpdateLocation(
    UpdateLocation event,
    Emitter<LocationState> emit,
  ) async {
    _ensureInitialized();
    emit(const LocationLoading());
  }

  Future<void> _onUpdateLocations(
    UpdateLocations event,
    Emitter<LocationState> emit,
  ) async {
    _ensureInitialized();
    emit(const LocationLoading());
    Map<Location, String>? failedLocations;
    try {
      for (var location in event.locations) {
        try {
          await _cloudStorage.locationMethods.updateLocation(_userId!, location);
        } catch (e) {
          failedLocations ??= {};
          failedLocations[location] = e.toString();
        }
      }
      final locations = await _cloudStorage.locationMethods.getUserLocations(_userId!);
      emit(LocationsLoaded(locations: locations, failedLocations: failedLocations));
      _locations = locations;
    } catch (e) {
      emit(LocationsLoaded(locations: _locations, errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteLocation(
    DeleteLocation event,
    Emitter<LocationState> emit,
  ) async {
    _ensureInitialized();
    emit(const LocationLoading());
  }
}
