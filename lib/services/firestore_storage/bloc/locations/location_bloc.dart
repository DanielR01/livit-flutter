import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/locations/location_event.dart';
import 'package:livit/services/firestore_storage/bloc/locations/location_state.dart';
import 'package:livit/services/firestore_storage/bloc/firestore_storage/firestore_storage.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final FirestoreStorage _cloudStorage;
  final String _userId;

  LocationBloc({
    required FirestoreStorage cloudStorage,
    required String userId,
  })  : _cloudStorage = cloudStorage,
        _userId = userId,
        super(const LocationInitial()) {
    on<LoadUserLocations>(_onLoadUserLocations);
    on<CreateLocation>(_onCreateLocation);
    on<UpdateLocation>(_onUpdateLocation);
    on<DeleteLocation>(_onDeleteLocation);
    on<UpdateLocationMedia>(_onUpdateLocationMedia);
  }

  Future<void> _onLoadUserLocations(
    LoadUserLocations event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationLoading());
    try {
      final locations = await _cloudStorage.getUserLocations(_userId);
      emit(LocationsLoaded(locations: locations));
    } catch (e) {
      emit(LocationError(message: e.toString()));
    }
  }

  Future<void> _onUpdateLocationMedia(
    UpdateLocationMedia event,
    Emitter<LocationState> emit,
  ) async {
    if (state is! LocationsLoaded) return;

    emit(LocationLoading());
    try {
      final updatedLocation = await event.location.addMedia(images: event.images);
      await _cloudStorage.updateLocation(_userId, updatedLocation);

      final locations = await _cloudStorage.getUserLocations(_userId);
      emit(LocationsLoaded(locations: locations));
    } catch (e) {
      emit(LocationError(message: e.toString()));
    }
  }

  Future<void> _onCreateLocation(
    CreateLocation event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationLoading());
  }

  Future<void> _onUpdateLocation(
    UpdateLocation event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationLoading());
  }

  Future<void> _onDeleteLocation(
    DeleteLocation event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationLoading());
  }
}
