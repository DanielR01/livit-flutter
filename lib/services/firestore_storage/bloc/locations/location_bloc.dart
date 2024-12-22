import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/cloud_models/location/location.dart';
import 'package:livit/cloud_models/location/location_media.dart';
import 'package:livit/services/firestore_storage/bloc/locations/location_event.dart';
import 'package:livit/services/firestore_storage/bloc/locations/location_state.dart';
import 'package:livit/services/firestore_storage/firestore_storage/exceptions/locations_exceptions.dart';
import 'package:livit/services/firestore_storage/firestore_storage/firestore_storage.dart';
import 'package:livit/utilities/media/media_file_cleanup.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final FirestoreStorage _cloudStorage;
  List<Location> _cloudLocations = [];
  List<Location> _localSavedLocations = [];
  List<Location> _localUnsavedLocations = [];
  Map<String, LoadingState> _loadingStates = {};
  String? _userId;

  LocationBloc()
      : _cloudStorage = FirestoreStorage(),
        super(const LocationUninitialized()) {
    // Cloud Events
    on<InitializeLocationBloc>(_onInitializeLocationBloc);
    on<GetUserLocations>(_onGetUserLocations);
    on<CreateLocationsToCloud>(_onCreateLocationsToCloud);
    on<UpdateLocationToCloud>(_onUpdateLocationToCloud);
    on<UpdateLocationsToCloud>(_onUpdateLocationsToCloud);
    on<UpdateLocationsToCloudFromLocal>(_onUpdateLocationsToCloudFromLocal);
    on<DeleteLocationToCloud>(_onDeleteLocationToCloud);
    on<UpdateLocationsMediaToCloud>(_onUpdateLocationsMediaToCloud);
    // Local Events
    on<CreateLocationLocally>(_onCreateLocationLocally);
    on<UpdateLocationLocally>(_onUpdateLocationLocally);
    on<DeleteLocationLocally>(_onDeleteLocationLocally);
    on<UpdateLocationMediaLocally>(_onUpdateLocationMediaLocally);
    on<SaveChangesLocally>(_onSaveChangesLocally);
  }

  bool get isInitialized => _userId != null;

  List<Location> get locations => _localUnsavedLocations.isNotEmpty ? _localUnsavedLocations : _localSavedLocations.isNotEmpty ? _localSavedLocations : _cloudLocations;

  bool get isCloudLoading => _loadingStates['cloud'] == LoadingState.loading;

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
    add(GetUserLocations());
  }

  // Cloud Events

  Future<void> _onGetUserLocations(
    GetUserLocations event,
    Emitter<LocationState> emit,
  ) async {
    _ensureInitialized();

    _loadingStates = {..._loadingStates, 'cloud': LoadingState.loading};
    emit(LocationsLoaded(
      cloudLocations: _cloudLocations,
      localSavedLocations: _localSavedLocations,
      localUnsavedLocations: _localUnsavedLocations,
      loadingStates: _loadingStates,
    ));

    try {
      final locations = await _cloudStorage.locationMethods.getUserLocations(_userId!);
      _loadingStates = {..._loadingStates, 'cloud': LoadingState.loaded};

      emit(LocationsLoaded(
        cloudLocations: locations,
        localSavedLocations: [],
        localUnsavedLocations: [],
        loadingStates: _loadingStates,
      ));

      for (var unsavedLocation in _localUnsavedLocations) {
        MediaFileCleanup.cleanupLocationMediaFile(unsavedLocation.media?.mainFile);
        for (var secondaryFile in unsavedLocation.media?.secondaryFiles ?? []) {
          MediaFileCleanup.cleanupLocationMediaFile(secondaryFile);
        }
      }

      for (var savedLocation in _localSavedLocations) {
        MediaFileCleanup.cleanupLocationMediaFile(savedLocation.media?.mainFile);
        for (var secondaryFile in savedLocation.media?.secondaryFiles ?? []) {
          MediaFileCleanup.cleanupLocationMediaFile(secondaryFile);
        }
      }

      _cloudLocations = locations;
      _localSavedLocations = [];
      _localUnsavedLocations = [];
    } catch (e) {
      emit(LocationsLoaded(
          cloudLocations: _cloudLocations,
          localSavedLocations: _localSavedLocations,
          localUnsavedLocations: _localUnsavedLocations,
          loadingStates: _loadingStates,
          errorMessage: e.toString()));
    }
  }

  Future<void> _onCreateLocationsToCloud(
    CreateLocationsToCloud event,
    Emitter<LocationState> emit,
  ) async {
    _ensureInitialized();
    _loadingStates = {..._loadingStates, 'cloud': LoadingState.loading};
    emit(LocationsLoaded(
      cloudLocations: _cloudLocations,
      localSavedLocations: _localSavedLocations,
      localUnsavedLocations: _localUnsavedLocations,
      loadingStates: _loadingStates,
    ));
    final Map<Location, String> failedLocations = {};
    for (var location in event.locations) {
      try {
        await _cloudStorage.locationMethods.createLocation(_userId!, location);
        _loadingStates = {..._loadingStates, location.id: LoadingState.loaded};
      } catch (e) {
        failedLocations[location] = e.toString();
        _loadingStates = {..._loadingStates, location.id: LoadingState.error};
      }
    }
    final locations = await _cloudStorage.locationMethods.getUserLocations(_userId!);
    _cloudLocations = locations;
    _loadingStates = {..._loadingStates, 'cloud': LoadingState.loaded};
    emit(LocationsLoaded(
      cloudLocations: _cloudLocations,
      localSavedLocations: failedLocations.isEmpty ? [] : event.locations,
      localUnsavedLocations: [],
      loadingStates: _loadingStates,
      failedLocations: failedLocations,
    ));
  }

  Future<void> _onUpdateLocationToCloud(
    UpdateLocationToCloud event,
    Emitter<LocationState> emit,
  ) async {
    _ensureInitialized();
    _loadingStates = {..._loadingStates, 'cloud': LoadingState.loading, event.location.id: LoadingState.loading};
    emit(LocationsLoaded(
      cloudLocations: _cloudLocations,
      localSavedLocations: _localSavedLocations,
      localUnsavedLocations: _localUnsavedLocations,
      loadingStates: _loadingStates,
    ));
    try {
      await _cloudStorage.locationMethods.updateLocation(_userId!, event.location);
      _loadingStates = {..._loadingStates, event.location.id: LoadingState.loaded, 'cloud': LoadingState.loaded};
      _localSavedLocations = [];
      _localUnsavedLocations = [];
      final updatedLocation = await _cloudStorage.locationMethods.getLocation(_userId!, event.location.id);
      _cloudLocations = _cloudLocations.map((location) => location.id == event.location.id ? updatedLocation : location).toList();
      emit(LocationsLoaded(
        cloudLocations: _cloudLocations,
        localSavedLocations: _localSavedLocations,
        localUnsavedLocations: _localUnsavedLocations,
        loadingStates: _loadingStates,
      ));
    } on LocationException catch (e) {
      _loadingStates = {..._loadingStates, event.location.id: LoadingState.error, 'cloud': LoadingState.loaded};

      emit(LocationsLoaded(
        cloudLocations: _cloudLocations,
        localSavedLocations: _localSavedLocations,
        localUnsavedLocations: _localUnsavedLocations,
        loadingStates: _loadingStates,
        errorMessage: e.code,
      ));
    } catch (e) {
      _loadingStates = {..._loadingStates, event.location.id: LoadingState.error, 'cloud': LoadingState.loaded};
      emit(LocationsLoaded(
        cloudLocations: _cloudLocations,
        localSavedLocations: _localSavedLocations,
        localUnsavedLocations: _localUnsavedLocations,
        loadingStates: _loadingStates,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateLocationsToCloud(
    UpdateLocationsToCloud event,
    Emitter<LocationState> emit,
  ) async {
    _ensureInitialized();
    _loadingStates = {..._loadingStates, 'cloud': LoadingState.loading};
    emit(LocationsLoaded(
      cloudLocations: _cloudLocations,
      localSavedLocations: _localSavedLocations,
      localUnsavedLocations: _localUnsavedLocations,
      loadingStates: _loadingStates,
    ));
    final Map<Location, String> failedLocations = {};
    for (var location in event.locations) {
      try {
        await _cloudStorage.locationMethods.updateLocation(_userId!, location);
        _loadingStates = {..._loadingStates, location.id: LoadingState.loaded};
      } catch (e) {
        failedLocations[location] = e.toString();
        _loadingStates = {..._loadingStates, location.id: LoadingState.error};
      }
    }
    final locations = await _cloudStorage.locationMethods.getUserLocations(_userId!);
    _cloudLocations = locations;
    _loadingStates = {..._loadingStates, 'cloud': LoadingState.loaded};
    emit(LocationsLoaded(
      cloudLocations: _cloudLocations,
      localSavedLocations: failedLocations.isEmpty ? [] : event.locations,
      localUnsavedLocations: [],
      loadingStates: _loadingStates,
      failedLocations: failedLocations,
    ));
  }

  Future<void> _onUpdateLocationsToCloudFromLocal(
    UpdateLocationsToCloudFromLocal event,
    Emitter<LocationState> emit,
  ) async {
    add(UpdateLocationsToCloud(locations: _localSavedLocations));
  }

  Future<void> _onDeleteLocationToCloud(
    DeleteLocationToCloud event,
    Emitter<LocationState> emit,
  ) async {
    _ensureInitialized();
    _loadingStates = {..._loadingStates, 'cloud': LoadingState.loading, event.location.id: LoadingState.loading};
    emit(LocationsLoaded(
      cloudLocations: _cloudLocations,
      localSavedLocations: _localSavedLocations,
      localUnsavedLocations: _localUnsavedLocations,
      loadingStates: _loadingStates,
    ));
    try {
      await _cloudStorage.locationMethods.deleteLocation(_userId!, event.location);
      _loadingStates = {..._loadingStates, event.location.id: LoadingState.loaded, 'cloud': LoadingState.loaded};
      _cloudLocations = _cloudLocations.where((location) => location.id != event.location.id).toList();
      emit(LocationsLoaded(
        cloudLocations: _cloudLocations,
        localSavedLocations: _localSavedLocations,
        localUnsavedLocations: _localUnsavedLocations,
        loadingStates: _loadingStates,
      ));
    } on LocationException catch (e) {
      _loadingStates = {..._loadingStates, event.location.id: LoadingState.error, 'cloud': LoadingState.loaded};
      emit(LocationsLoaded(
        cloudLocations: _cloudLocations,
        localSavedLocations: _localSavedLocations,
        localUnsavedLocations: _localUnsavedLocations,
        loadingStates: _loadingStates,
        errorMessage: e.code,
      ));
    } catch (e) {
      _loadingStates = {..._loadingStates, event.location.id: LoadingState.error, 'cloud': LoadingState.loaded};
      emit(LocationsLoaded(
        cloudLocations: _cloudLocations,
        localSavedLocations: _localSavedLocations,
        localUnsavedLocations: _localUnsavedLocations,
        loadingStates: _loadingStates,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateLocationsMediaToCloud(
    UpdateLocationsMediaToCloud event,
    Emitter<LocationState> emit,
  ) async {
    _ensureInitialized();
    for (final location in event.locations) {
      _loadingStates = {..._loadingStates, location.id: LoadingState.loading};
    }
    _loadingStates = {..._loadingStates, 'cloud': LoadingState.loading};
    emit(LocationsLoaded(
      cloudLocations: _cloudLocations,
      localSavedLocations: _localSavedLocations,
      localUnsavedLocations: _localUnsavedLocations,
      loadingStates: _loadingStates,
    ));
    //TODO: Implement update locations media to cloud with cloud functions, use url to detecte if the file is already uploaded
  }

  // Local Events

  Future<void> _onCreateLocationLocally(
    CreateLocationLocally event,
    Emitter<LocationState> emit,
  ) async {
    _ensureInitialized();
    _localUnsavedLocations = [..._localUnsavedLocations.isNotEmpty ? _localUnsavedLocations : _cloudLocations, event.location];
    emit(LocationsLoaded(
      cloudLocations: _cloudLocations,
      localSavedLocations: _localSavedLocations,
      localUnsavedLocations: _localUnsavedLocations,
      loadingStates: _loadingStates,
    ));
  }

  Future<void> _onUpdateLocationLocally(
    UpdateLocationLocally event,
    Emitter<LocationState> emit,
  ) async {
    _ensureInitialized();
    try {
      final Location oldLocation = _localUnsavedLocations.firstWhere(
        (location) => location.id == event.location.id,
        orElse: () => throw Exception("Location not found"),
      );
      
      if (oldLocation.media != event.location.media) {
        throw Exception("Event not allowed to update media");
      }
      _localUnsavedLocations =
          _localUnsavedLocations.map((location) => location.id == event.location.id ? event.location : location).toList();
      emit(LocationsLoaded(
        cloudLocations: _cloudLocations,
        localSavedLocations: _localSavedLocations,
        localUnsavedLocations: _localUnsavedLocations,
        loadingStates: _loadingStates,
      ));
    } catch (e) {
      emit(LocationsLoaded(
        cloudLocations: _cloudLocations,
        localSavedLocations: _localSavedLocations,
        localUnsavedLocations: _localUnsavedLocations,
        loadingStates: _loadingStates,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteLocationLocally(
    DeleteLocationLocally event,
    Emitter<LocationState> emit,
  ) async {
    _ensureInitialized();
    _localUnsavedLocations = _localUnsavedLocations.where((location) => location.id != event.location.id).toList();
    MediaFileCleanup.cleanupLocationMediaFile(event.location.media?.mainFile);
    for (var secondaryFile in event.location.media?.secondaryFiles ?? []) {
      MediaFileCleanup.cleanupLocationMediaFile(secondaryFile);
    }
    emit(LocationsLoaded(
      cloudLocations: _cloudLocations,
      localSavedLocations: _localSavedLocations,
      localUnsavedLocations: _localUnsavedLocations,
      loadingStates: _loadingStates,
    ));
  }

  Future<void> _onUpdateLocationMediaLocally(
    UpdateLocationMediaLocally event,
    Emitter<LocationState> emit,
  ) async {
    _ensureInitialized();

    if (_localUnsavedLocations.isEmpty) {
      _localUnsavedLocations = _cloudLocations;
      _localSavedLocations = _cloudLocations;
    }

    final int oldUnsavedLocationIndex = _localUnsavedLocations.indexWhere((location) => location.id == event.location.id);
    final LivitLocationMedia? oldUnsavedLocationMedia = _localUnsavedLocations[oldUnsavedLocationIndex].media;
    final LivitLocationMedia? oldSavedLocationMedia = _localSavedLocations.firstWhere((location) => location.id == event.location.id).media;
    final LivitLocationMedia? newLocationMedia = event.location.media;

    final List<String?> allOldUnsavedLocationMediaFilesPaths = [
      if (oldUnsavedLocationMedia?.mainFile != null) oldUnsavedLocationMedia!.mainFile!.filePath,
      ...?oldUnsavedLocationMedia?.secondaryFiles?.map((file) => file?.filePath)
    ];

    final List<String?> allNewLocationMediaFilesPaths = [
      if (newLocationMedia?.mainFile != null) newLocationMedia!.mainFile!.filePath,
      ...?newLocationMedia?.secondaryFiles?.map((file) => file?.filePath)
    ];

    final List<String?> allOldSavedLocationMediaFilesPaths = [
      if (oldSavedLocationMedia?.mainFile != null) oldSavedLocationMedia!.mainFile!.filePath,
      ...?oldSavedLocationMedia?.secondaryFiles?.map((file) => file?.filePath)
    ];

    final List<String?> newFilePaths = allOldUnsavedLocationMediaFilesPaths.where((path) => !allNewLocationMediaFilesPaths.contains(path)).toList();

    final List<String?> filePathsToDelete = newFilePaths.where((path) => !allOldSavedLocationMediaFilesPaths.contains(path)).toList();

    for (var filePath in filePathsToDelete) {
      MediaFileCleanup.deleteFileByPath(filePath);
    }
    
    _localUnsavedLocations[oldUnsavedLocationIndex] = _localUnsavedLocations[oldUnsavedLocationIndex].copyWith(media: event.media);


    emit(LocationsLoaded(
      cloudLocations: _cloudLocations,
      localSavedLocations: _localSavedLocations,
      localUnsavedLocations: _localUnsavedLocations,
      loadingStates: _loadingStates,
    ));
  }

  Future<void> _onSaveChangesLocally(
    SaveChangesLocally event,
    Emitter<LocationState> emit,
  ) async {
    _ensureInitialized();
    List<String?> newFilePaths = [];
    for (var newLocation in _localUnsavedLocations) {
      newFilePaths.addAll([
        if (newLocation.media?.mainFile != null) newLocation.media!.mainFile!.filePath,
        ...?newLocation.media?.secondaryFiles?.map((file) => file?.filePath)
      ]);
    }
    List<String?> oldFilePaths = [];
    for (var oldSavedlocation in _localSavedLocations) {
      oldFilePaths.addAll([
        if (oldSavedlocation.media?.mainFile != null) oldSavedlocation.media!.mainFile!.filePath,
        ...?oldSavedlocation.media?.secondaryFiles?.map((file) => file?.filePath)
      ]);
    }

    List<String?> filePathsToDelete = oldFilePaths.where((path) => !newFilePaths.contains(path)).toList();

    for (var filePath in filePathsToDelete) {
      MediaFileCleanup.deleteFileByPath(filePath);
    }

    _localSavedLocations = _localUnsavedLocations;
    
    _localUnsavedLocations = [];
    emit(LocationsLoaded(
      cloudLocations: _cloudLocations,
      localSavedLocations: _localSavedLocations,
      localUnsavedLocations: _localUnsavedLocations,
      loadingStates: _loadingStates,
    ));
  }

  Map<String, bool> isLocationValid(Location location) {
    final bool isNameValid = location.name != '' && 
                           location.name.isNotEmpty && 
                           location.name.length < 30;
    
    final bool isAddressValid = location.address != '' && 
                               location.address.isNotEmpty && 
                               location.address.length < 50;
    
    final bool isDepartmentValid = location.department != '' && 
                                  location.department.isNotEmpty;
    
    final bool isCityValid = location.city != '' && 
                            location.city.isNotEmpty;
    
    final bool isDescriptionValid = (location.description?.length ?? 0) <= 50;
    
    final bool isMediaValid = location.media?.mainFile?.filePath != null;

    return {
      'isValid': isNameValid && isAddressValid && isDepartmentValid && isCityValid && isDescriptionValid && isMediaValid,
      'isValidWithoutMedia': isNameValid && isAddressValid && isDepartmentValid && isCityValid && isDescriptionValid,
      'isNameValid': isNameValid,
      'isAddressValid': isAddressValid,
      'isDepartmentValid': isDepartmentValid,
      'isCityValid': isCityValid,
      'isDescriptionValid': isDescriptionValid,
      'isMediaValid': isMediaValid
    };
  }

  bool get areAllLocationsValid => 
    locations.every((location) => isLocationValid(location)['isValid'] as bool);

  bool get areAllLocationsValidWithoutMedia => 
    locations.every((location) => isLocationValid(location)['isValidWithoutMedia'] as bool);
}
