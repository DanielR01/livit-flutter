import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/models/location/location.dart';
import 'package:livit/models/location/location_media.dart';
import 'package:livit/models/media/location_media_file.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/services/background/background_bloc.dart';
import 'package:livit/services/background/background_events.dart';
import 'package:livit/services/exceptions/base_exception.dart';
import 'package:livit/services/firebase_storage/bloc/storage_bloc.dart';
import 'package:livit/services/firebase_storage/bloc/storage_event.dart';
import 'package:livit/services/firebase_storage/bloc/storage_state.dart';
import 'package:livit/services/firebase_storage/firebase_storage_constants.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_bloc_exception.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_event.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_state.dart';
import 'package:livit/services/firestore_storage/bloc/user/user_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/user/user_event.dart';
import 'package:livit/services/firestore_storage/bloc/user/user_state.dart';
import 'package:livit/services/cloud_functions/firestore_cloud_functions.dart';
import 'package:livit/services/firestore_storage/firestore_storage/exceptions/locations_exceptions.dart';
import 'package:livit/services/firestore_storage/firestore_storage/firestore_storage.dart';
import 'package:livit/services/navigation/navigation_service.dart';
import 'package:livit/utilities/media/media_file_cleanup.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final FirestoreStorageService _firestoreStorage;
  final FirestoreCloudFunctions _cloudFunctions;
  final BackgroundBloc _backgroundBloc;
  final StorageBloc _storageBloc;
  final UserBloc _userBloc;
  List<LivitLocation> _cloudLocations = [];
  List<LivitLocation> _localSavedLocations = [];
  List<LivitLocation> _localUnsavedLocations = [];
  Map<String, LoadingState> _loadingStates = {};
  String? _userId;

  LivitLocation? currentLocation;

  LocationBloc({
    required FirestoreStorageService firestoreStorage,
    required FirestoreCloudFunctions cloudFunctions,
    required BackgroundBloc backgroundBloc,
    required StorageBloc storageBloc,
    required UserBloc userBloc,
  })  : _firestoreStorage = firestoreStorage,
        _cloudFunctions = cloudFunctions,
        _backgroundBloc = backgroundBloc,
        _storageBloc = storageBloc,
        _userBloc = userBloc,
        super(const LocationUninitialized()) {
    // Cloud Events
    on<InitializeLocationBloc>(_onInitializeLocationBloc);
    on<GetUserLocations>(_onGetUserLocations);
    on<CreateLocationsToCloud>(_onCreateLocationsToCloud);
    on<CreateLocationsToCloudFromLocal>(_onCreateLocationsToCloudFromLocal);
    on<UpdateLocationToCloud>(_onUpdateLocationToCloud);
    on<UpdateLocationsToCloud>(_onUpdateLocationsToCloud);
    on<UpdateLocationsToCloudFromLocal>(_onUpdateLocationsToCloudFromLocal);
    on<DeleteLocationToCloud>(_onDeleteLocationToCloud);
    on<UpdateLocationsMediaToCloud>(_onUpdateLocationsMediaToCloud);
    on<UpdateLocationsMediaToCloudFromLocal>(_onUpdateLocationsMediaToCloudFromLocal);
    on<SkipUpdateLocationsMediaToCloud>(_onSkipUpdateLocationsMediaToCloud);
    // Local Events
    on<CreateLocationLocally>(_onCreateLocationLocally);
    on<UpdateLocationLocally>(_onUpdateLocationLocally);
    on<DeleteLocationLocally>(_onDeleteLocationLocally);
    on<UpdateLocationMediaLocally>(_onUpdateLocationMediaLocally);
    on<SaveChangesLocally>(_onSaveChangesLocally);
    on<DiscardChangesLocally>(_onDiscardChangesLocally);
    on<SetCurrentLocation>(_onSetCurrentLocation);
  }

  bool get isInitialized => _userId != null;

  List<LivitLocation> get locations => _localUnsavedLocations.isNotEmpty
      ? _localUnsavedLocations
      : _localSavedLocations.isNotEmpty
          ? _localSavedLocations
          : _cloudLocations;

  bool get isCloudLoading => _loadingStates['cloud'] == LoadingState.loading;

  bool get areUnsavedChanges => _localUnsavedLocations.isNotEmpty;

  void _ensureInitialized() {
    if (!isInitialized) {
      throw StateError('LocationBloc must be initialized with InitializeLocationBloc before using other events');
    }
  }

  Future<void> _onInitializeLocationBloc(
    InitializeLocationBloc event,
    Emitter<LocationState> emit,
  ) async {
    if (_userBloc.state is! CurrentUser) {
      debugPrint('❌ [LocationBloc] UserBloc is not initialized');
      return;
    }
    _userId = (_userBloc.state as CurrentUser).user.id;
    debugPrint('🔄 [LocationBloc] Initializing bloc for user: $_userId');
    await _onGetUserLocations(GetUserLocations(event.context), emit);
  }

  // Cloud Events

  Future<void> _onGetUserLocations(
    GetUserLocations event,
    Emitter<LocationState> emit,
  ) async {
    _ensureInitialized();
    debugPrint('📥 [LocationBloc] Getting user locations from cloud');
    _backgroundBloc.add(BackgroundStartLoadingAnimation());

    _loadingStates = {..._loadingStates, 'cloud': LoadingState.loading};
    emit(LocationsLoaded(
      cloudLocations: _cloudLocations,
      localSavedLocations: _localSavedLocations,
      localUnsavedLocations: _localUnsavedLocations,
      loadingStates: _loadingStates,
    ));

    try {
      final locations = await _firestoreStorage.locationService.getUserLocations(_userId!);
      debugPrint('✅ [LocationBloc] Got ${locations.length} locations from cloud');
      _loadingStates = {..._loadingStates, 'cloud': LoadingState.loaded};
      //await Future.delayed(const Duration(milliseconds: 10000));
      emit(LocationsLoaded(
        cloudLocations: locations,
        localSavedLocations: [],
        localUnsavedLocations: [],
        loadingStates: _loadingStates,
      ));
      if (event.context.mounted) {
        event.context.read<BackgroundBloc>().add(BackgroundStopLoadingAnimation());
      }

      for (var unsavedLocation in _localUnsavedLocations) {
        for (var file in unsavedLocation.media?.files ?? []) {
          MediaFileCleanup.cleanupLocationMediaFile(file);
        }
      }

      for (var savedLocation in _localSavedLocations) {
        for (var file in savedLocation.media?.files ?? []) {
          MediaFileCleanup.cleanupLocationMediaFile(file);
        }
      }

      _cloudLocations = locations;
      _localSavedLocations = [];
      _localUnsavedLocations = [];
      if (locations.isNotEmpty) {
        currentLocation = locations.first;
      }
    } catch (e) {
      debugPrint('❌ [LocationBloc] Error getting locations: $e');
      emit(LocationsLoaded(
          cloudLocations: _cloudLocations,
          localSavedLocations: _localSavedLocations,
          localUnsavedLocations: _localUnsavedLocations,
          loadingStates: _loadingStates,
          errorMessage: e.toString()));
    } finally {
      _backgroundBloc.add(BackgroundStopLoadingAnimation());
    }
  }

  Future<void> _onCreateLocationsToCloud(
    CreateLocationsToCloud event,
    Emitter<LocationState> emit,
  ) async {
    try {
      debugPrint('📤 [LocationBloc] Creating ${event.locations.length} locations to cloud');
      _ensureInitialized();
      event.context.read<BackgroundBloc>().add(BackgroundStartLoadingAnimation());
      _loadingStates = {};
      _loadingStates = {..._loadingStates, 'cloud': LoadingState.loading};
      emit(LocationsLoaded(
        cloudLocations: _cloudLocations,
        localSavedLocations: _localSavedLocations,
        localUnsavedLocations: _localUnsavedLocations,
        loadingStates: _loadingStates,
      ));
      final Map<LivitLocation, Map<String, LivitException>> failedLocations = {};
      for (var location in event.locations) {
        try {
          debugPrint('📥 [LocationBloc] Creating location ${location.name}');
          await _cloudFunctions.createLocation(location: location);
          _loadingStates = {..._loadingStates, location.id: LoadingState.loaded};
        } catch (e) {
          debugPrint('❌ [LocationBloc] Failed to create location ${location.name}: $e');
          failedLocations[location] = {'error': e is LivitException ? e : GenericLocationBlocException()};
          _loadingStates = {..._loadingStates, location.id: LoadingState.error};
        }
      }
      debugPrint('📥 [LocationBloc] Getting user data and locations from cloud after creating locations');
      final locations = await _firestoreStorage.locationService.getUserLocations(_userId!);
      // ignore: use_build_context_synchronously
      _userBloc.add(GetUser(event.context));
      debugPrint('✅ [LocationBloc] Got ${locations.length} locations from cloud after creating locations');
      _cloudLocations = locations;
      _loadingStates = {..._loadingStates, 'cloud': LoadingState.loaded};
      _localUnsavedLocations = failedLocations.isEmpty ? [] : event.locations;
      _localSavedLocations = [];
      emit(LocationsLoaded(
        cloudLocations: failedLocations.isEmpty ? _cloudLocations : [],
        localSavedLocations: _localSavedLocations,
        localUnsavedLocations: _localUnsavedLocations,
        loadingStates: _loadingStates,
        failedLocations: failedLocations,
      ));
      _backgroundBloc.add(BackgroundStopLoadingAnimation());
      debugPrint('✅ [LocationBloc] Finished creating locations');
    } catch (e) {
      debugPrint('❌ [LocationBloc] Failed to create locations: $e');
      _backgroundBloc.add(BackgroundStopLoadingAnimation());
      emit(LocationsLoaded(
        cloudLocations: _cloudLocations,
        localSavedLocations: _localSavedLocations,
        localUnsavedLocations: _localUnsavedLocations,
        loadingStates: _loadingStates,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCreateLocationsToCloudFromLocal(
    CreateLocationsToCloudFromLocal event,
    Emitter<LocationState> emit,
  ) async {
    try {
      debugPrint('📤 [LocationBloc] Creating ${locations.length} locations to cloud from local');
      _ensureInitialized();
      event.context.read<BackgroundBloc>().add(BackgroundStartLoadingAnimation());

      final completer = Completer<void>();

      final subscription = stream.listen((state) {
        if (state is LocationsLoaded && _localUnsavedLocations.isEmpty && !completer.isCompleted) {
          completer.complete();
        }
      });

      add(SaveChangesLocally(event.context));

      await completer.future;
      await subscription.cancel();

      if (event.context.mounted) {
        add(CreateLocationsToCloud(event.context, _localSavedLocations));
      }
    } catch (e) {
      debugPrint('❌ [LocationBloc] Failed to create locations from local: $e');
    }
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
    event.context.read<BackgroundBloc>().add(BackgroundStartLoadingAnimation());
    try {
      await _firestoreStorage.locationService.updateLocation(event.location);
      _loadingStates = {..._loadingStates, event.location.id: LoadingState.loaded, 'cloud': LoadingState.loaded};
      _localSavedLocations = [];
      _localUnsavedLocations = [];
      final updatedLocation = await _firestoreStorage.locationService.getLocation(event.location.id);
      _cloudLocations = _cloudLocations.map((location) => location.id == event.location.id ? updatedLocation : location).toList();
      emit(LocationsLoaded(
        cloudLocations: _cloudLocations,
        localSavedLocations: _localSavedLocations,
        localUnsavedLocations: _localUnsavedLocations,
        loadingStates: _loadingStates,
      ));
      _backgroundBloc.add(BackgroundStopLoadingAnimation());
    } on LocationException catch (e) {
      _loadingStates = {..._loadingStates, event.location.id: LoadingState.error, 'cloud': LoadingState.loaded};

      emit(LocationsLoaded(
        cloudLocations: _cloudLocations,
        localSavedLocations: _localSavedLocations,
        localUnsavedLocations: _localUnsavedLocations,
        loadingStates: _loadingStates,
        errorMessage: e.code,
      ));
      _backgroundBloc.add(BackgroundStopLoadingAnimation());
    } catch (e) {
      _loadingStates = {..._loadingStates, event.location.id: LoadingState.error, 'cloud': LoadingState.loaded};
      emit(LocationsLoaded(
        cloudLocations: _cloudLocations,
        localSavedLocations: _localSavedLocations,
        localUnsavedLocations: _localUnsavedLocations,
        loadingStates: _loadingStates,
        errorMessage: e.toString(),
      ));
      _backgroundBloc.add(BackgroundStopLoadingAnimation());
    }
  }

  Future<void> _onUpdateLocationsToCloud(
    UpdateLocationsToCloud event,
    Emitter<LocationState> emit,
  ) async {
    debugPrint('📤 [LocationBloc] Updating ${event.locations.length} locations to cloud');
    _ensureInitialized();
    _loadingStates = {..._loadingStates, 'cloud': LoadingState.loading};
    emit(LocationsLoaded(
      cloudLocations: _cloudLocations,
      localSavedLocations: _localSavedLocations,
      localUnsavedLocations: _localUnsavedLocations,
      loadingStates: _loadingStates,
    ));
    event.context.read<BackgroundBloc>().add(BackgroundStartLoadingAnimation());
    final Map<LivitLocation, Map<String, LivitException>> failedLocations = {};
    for (var location in event.locations) {
      try {
        debugPrint('📥 [LocationBloc] Updating location ${location.name}');
        await _firestoreStorage.locationService.updateLocation(location);
        _loadingStates = {..._loadingStates, location.id: LoadingState.loaded};
      } catch (e) {
        debugPrint('❌ [LocationBloc] Failed to update location ${location.name}: $e');
        failedLocations[location] = {'error': e is LivitException ? e : GenericLocationBlocException()};
        _loadingStates = {..._loadingStates, location.id: LoadingState.error};
      }
    }
    final locations = await _firestoreStorage.locationService.getUserLocations(_userId!);
    _cloudLocations = locations;
    _localUnsavedLocations = failedLocations.isEmpty ? [] : event.locations;
    _localSavedLocations = [];
    _loadingStates = {..._loadingStates, 'cloud': LoadingState.loaded};
    emit(LocationsLoaded(
      cloudLocations: _cloudLocations,
      localSavedLocations: _localSavedLocations,
      localUnsavedLocations: _localUnsavedLocations,
      loadingStates: _loadingStates,
      failedLocations: failedLocations,
    ));
    _backgroundBloc.add(BackgroundStopLoadingAnimation());
    debugPrint('✅ [LocationBloc] Finished updating locations');
  }

  Future<void> _onUpdateLocationsToCloudFromLocal(
    UpdateLocationsToCloudFromLocal event,
    Emitter<LocationState> emit,
  ) async {
    final completer = Completer<void>();

    final subscription = stream.listen((state) {
      if (state is LocationsLoaded && _localUnsavedLocations.isEmpty && !completer.isCompleted) {
        completer.complete();
      }
    });

    add(SaveChangesLocally(event.context));

    await completer.future;
    await subscription.cancel();

    if (event.context.mounted) {
      add(UpdateLocationsToCloud(event.context, locations: _localSavedLocations));
    }
  }

  Future<void> _onUpdateLocationsMediaToCloudFromLocal(
    UpdateLocationsMediaToCloudFromLocal event,
    Emitter<LocationState> emit,
  ) async {
    debugPrint('📤 [LocationBloc] Updating media for ${_localSavedLocations.length} locations from local');
    final completer = Completer<void>();

    final subscription = stream.listen((state) {
      if (state is LocationsLoaded && _localUnsavedLocations.isEmpty && !completer.isCompleted) {
        completer.complete();
      }
    });

    add(SaveChangesLocally(event.context));

    await completer.future;
    await subscription.cancel();

    if (event.context.mounted) {
      add(UpdateLocationsMediaToCloud(event.context, locations: _localSavedLocations));
    }
  }

  Future<void> _onSkipUpdateLocationsMediaToCloud(
    SkipUpdateLocationsMediaToCloud event,
    Emitter<LocationState> emit,
  ) async {
    _loadingStates = {..._loadingStates, 'cloud': LoadingState.skipping};
    _backgroundBloc.add(BackgroundStartLoadingAnimation());
    emit(LocationsLoaded(
      cloudLocations: _cloudLocations,
      localSavedLocations: _localSavedLocations,
      localUnsavedLocations: _localUnsavedLocations,
      loadingStates: _loadingStates,
    ));
    final emptyLocationMedia = LivitLocationMedia();
    final List<LivitLocation> locationsToUpload = locations.map((location) => location.copyWith(media: emptyLocationMedia)).toList();
    try {
      Map<LivitLocation, String> failedLocations = {};
      debugPrint('⏭️ [LocationBloc] Skipping updating media for ${locationsToUpload.length} locations');
      for (var location in locationsToUpload) {
        try {
          await _firestoreStorage.locationService.updateLocation(location);
          _loadingStates = {..._loadingStates, location.id: LoadingState.loaded};
        } catch (e) {
          debugPrint('❌ [LocationBloc] Failed to update location ${location.name}: $e');
          failedLocations[location] = e.toString();
          _loadingStates = {..._loadingStates, location.id: LoadingState.error};
        }
      }
      add(GetUserLocations(event.context));
    } catch (e) {
      debugPrint('❌ [LocationBloc] Failed to skip updating media for locations: $e');
      for (var location in locationsToUpload) {
        _loadingStates = {..._loadingStates, location.id: LoadingState.error};
      }
      _loadingStates = {..._loadingStates, 'cloud': LoadingState.loaded};
      emit(LocationsLoaded(
        cloudLocations: _cloudLocations,
        localSavedLocations: _localSavedLocations,
        localUnsavedLocations: _localUnsavedLocations,
        loadingStates: _loadingStates,
        errorMessage: e.toString(),
      ));
    } finally {
      _backgroundBloc.add(BackgroundStopLoadingAnimation());
    }
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
    event.context.read<BackgroundBloc>().add(BackgroundStartLoadingAnimation());
    try {
      await _firestoreStorage.locationService.deleteLocation(event.location);
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
    if (event.context.mounted) {
      event.context.read<BackgroundBloc>().add(BackgroundStopLoadingAnimation());
    }
  }

  Future<void> _onUpdateLocationsMediaToCloud(
    UpdateLocationsMediaToCloud event,
    Emitter<LocationState> emit,
  ) async {
    debugPrint('📤 [LocationBloc] Updating media for ${event.locations.length} locations');
    _ensureInitialized();
    _loadingStates = {};
    for (final location in event.locations) {
      _loadingStates = {..._loadingStates, location.id: LoadingState.loading};
    }
    _loadingStates = {..._loadingStates, 'cloud': LoadingState.loading};
    debugPrint('🔍 [LocationBloc] Loading states: $_loadingStates');
    emit(LocationsLoaded(
      cloudLocations: _cloudLocations,
      localSavedLocations: _localSavedLocations,
      localUnsavedLocations: _localUnsavedLocations,
      loadingStates: _loadingStates,
    ));
    debugPrint('▶️ [LocationBloc] Starting background loading animation');
    event.context.read<BackgroundBloc>().add(BackgroundStartLoadingAnimation());
    final Map<LivitLocation, Map<String, LivitException>> failedLocations = {};
    try {
      for (final location in event.locations) {
        debugPrint('🔍 [LocationBloc] Verifying location ${location.id} media');
        if (location.media?.files?.any((file) {
              if (file is LivitMediaVideo) {
                return file.cover.filePath == null ||
                    file.filePath == null ||
                    !File(file.cover.filePath!).existsSync() ||
                    !File(file.filePath!).existsSync();
              }
              return file?.filePath == null || !File(file?.filePath ?? '').existsSync();
            }) ==
            true) {
          debugPrint('❌ [LocationBloc] Location ${location.id} has a media file with no path');
          _loadingStates = {..._loadingStates, location.id: LoadingState.error};
          failedLocations[location] = {'error': FileWithNoPathException()};
          location.media?.files?.forEach((file) {
            if (file is LivitMediaVideo) {
              if (!File(file.cover.filePath ?? '').existsSync() || !File(file.filePath ?? '').existsSync()) {
                failedLocations[location] = {
                  ...failedLocations[location] ?? {},
                  (location.media?.files?.indexOf(file)).toString(): FileWithNoPathException()
                };
              }
            } else if (file is LivitMediaImage) {
              if (file.filePath == null || !File(file.filePath!).existsSync()) {
                failedLocations[location] = {
                  ...failedLocations[location] ?? {},
                  (location.media?.files?.indexOf(file)).toString(): FileWithNoPathException()
                };
              }
            }
          });
        }
        if (location.media?.files?.isNotEmpty == true) {
          if ((location.media?.files?.length ?? 0) > FirebaseStorageConstants.maxFiles) {
            debugPrint('❌ [LocationBloc] Location ${location.id} has more than ${FirebaseStorageConstants.maxFiles} files');
            _loadingStates = {..._loadingStates, location.id: LoadingState.error};
            failedLocations[location] = {'error': LocationWithMoreThanMaxFilesException()};
          }
        }

        if (failedLocations.containsKey(location)) {
          debugPrint('⏭️ [LocationBloc] Skipping location ${location.id} because it has failed');
          continue;
        }
        _storageBloc.add(VerifyLocationMedia(location: location));
        await for (final state in _storageBloc.stream) {
          if (state is StorageLoaded) {
            final loadingState = state.loadingStates[location.id];
            if (loadingState == LoadingState.verified) {
              debugPrint('✅ [LocationBloc] Location ${location.id} media verified');
              _loadingStates = {..._loadingStates, location.id: LoadingState.verified};
              debugPrint('🔍 [LocationBloc] Loading states: $_loadingStates');
              emit(LocationsLoaded(
                cloudLocations: _cloudLocations,
                localSavedLocations: _localSavedLocations,
                localUnsavedLocations: _localUnsavedLocations,
                loadingStates: _loadingStates,
              ));
              break;
            } else if (loadingState == LoadingState.verifying) {
              debugPrint('🔄 [LocationBloc] Location ${location.id} media verifying');
              _loadingStates = {..._loadingStates, location.id: LoadingState.verifying};
              debugPrint('🔍 [LocationBloc] Loading states: $_loadingStates');
              emit(LocationsLoaded(
                cloudLocations: _cloudLocations,
                localSavedLocations: _localSavedLocations,
                localUnsavedLocations: _localUnsavedLocations,
                loadingStates: _loadingStates,
              ));
            } else if (loadingState == LoadingState.error) {
              debugPrint('❌ [LocationBloc] Location ${location.id} media verifying failed: ${state.exceptions?[location.id]}');
              failedLocations[location] = state.exceptions?[location.id] ?? {'error': GenericLocationBlocException()};
              _loadingStates = {..._loadingStates, location.id: LoadingState.error};
              debugPrint('🔍 [LocationBloc] Loading states: $_loadingStates');
              emit(LocationsLoaded(
                cloudLocations: _cloudLocations,
                localSavedLocations: _localSavedLocations,
                localUnsavedLocations: _localUnsavedLocations,
                loadingStates: _loadingStates,
              ));
              break;
            }
          }
        }

        if (failedLocations.containsKey(location)) {
          debugPrint('⏭️ [LocationBloc] Skipping location ${location.id} because it has failed');
          continue;
        }
        debugPrint('📞 [LocationBloc] Calling delete location media for ${location.id}');
        _storageBloc.add(DeleteLocationMedia(locationId: location.id));
        await for (final state in _storageBloc.stream) {
          if (state is StorageLoaded) {
            final loadingState = state.loadingStates[location.id];
            if (loadingState == LoadingState.deleted) {
              debugPrint('🗑️[LocationBloc] Location ${location.id} media deleted');
              _loadingStates = {..._loadingStates, location.id: LoadingState.deleted};
              debugPrint('🔍 [LocationBloc] Loading states: $_loadingStates');
              emit(LocationsLoaded(
                cloudLocations: _cloudLocations,
                localSavedLocations: _localSavedLocations,
                localUnsavedLocations: _localUnsavedLocations,
                loadingStates: _loadingStates,
              ));
              break;
            } else if (loadingState == LoadingState.deleting) {
              debugPrint('🔄 [LocationBloc] Location ${location.id} media deleting');
              _loadingStates = {..._loadingStates, location.id: LoadingState.deleting};
              debugPrint('🔍 [LocationBloc] Loading states: $_loadingStates');
              emit(LocationsLoaded(
                cloudLocations: _cloudLocations,
                localSavedLocations: _localSavedLocations,
                localUnsavedLocations: _localUnsavedLocations,
                loadingStates: _loadingStates,
              ));
            } else if (loadingState == LoadingState.error && state.exceptions?[location.id] != null) {
              debugPrint('❌ [LocationBloc] Location ${location.id} media deleting failed: ${state.exceptions![location.id]}');
              failedLocations[location] = state.exceptions?[location.id] ?? {'error': GenericLocationBlocException()};
              _loadingStates = {..._loadingStates, location.id: LoadingState.error};
              debugPrint('🔍 [LocationBloc] Loading states: $_loadingStates');
              emit(LocationsLoaded(
                cloudLocations: _cloudLocations,
                localSavedLocations: _localSavedLocations,
                localUnsavedLocations: _localUnsavedLocations,
                loadingStates: _loadingStates,
              ));
              break;
            }
          }
        }
        if (failedLocations.containsKey(location)) {
          debugPrint('⏭️ [LocationBloc] Skipping location ${location.id} because it has failed');
          continue;
        }
        debugPrint('📞 [LocationBloc] Calling set location media for ${location.id}');
        _storageBloc.add(SetLocationMedia());
        await for (final state in _storageBloc.stream) {
          if (state is StorageLoaded) {
            final loadingState = state.loadingStates[location.id];
            if (loadingState == LoadingState.uploaded) {
              debugPrint('✅ [LocationBloc] Location ${location.id} media uploaded');
              if (state.exceptions?.isNotEmpty == true) {
                failedLocations[location] = {
                  ...failedLocations[location] ?? {},
                  'error': state.exceptions?[location.id]?['error'] ?? GenericLocationBlocException(),
                };
                _loadingStates[location.id] = LoadingState.error;
              } else {
                _loadingStates[location.id] = LoadingState.uploaded;
              }
              debugPrint('🔍 [LocationBloc] Loading states: $_loadingStates');
              emit(LocationsLoaded(
                cloudLocations: _cloudLocations,
                localSavedLocations: _localSavedLocations,
                localUnsavedLocations: _localUnsavedLocations,
                loadingStates: _loadingStates,
              ));
              break;
            } else if (loadingState == LoadingState.uploading) {
              debugPrint('🔄 [LocationBloc] Location ${location.id} media uploading');
              _loadingStates = {..._loadingStates, location.id: LoadingState.uploading};
              debugPrint('🔍 [LocationBloc] Loading states: $_loadingStates');
              emit(LocationsLoaded(
                cloudLocations: _cloudLocations,
                localSavedLocations: _localSavedLocations,
                localUnsavedLocations: _localUnsavedLocations,
                loadingStates: _loadingStates,
              ));
            } else if (loadingState == LoadingState.error && state.exceptions?[location.id] != null) {
              debugPrint('❌ [LocationBloc] Location ${location.id} media uploading failed: ${state.exceptions![location.id]}');
              failedLocations[location] = state.exceptions?[location.id] ?? {'error': GenericLocationBlocException()};
              _loadingStates = {..._loadingStates, location.id: LoadingState.error};
              debugPrint('🔍 [LocationBloc] Loading states: $_loadingStates');
              emit(LocationsLoaded(
                cloudLocations: _cloudLocations,
                localSavedLocations: _localSavedLocations,
                localUnsavedLocations: _localUnsavedLocations,
                loadingStates: _loadingStates,
              ));
              break;
            }
          }
        }
      }

      bool atLeastOneLoaded = false;
      for (final loadingState in _loadingStates.values) {
        if (loadingState == LoadingState.uploaded) {
          atLeastOneLoaded = true;
          break;
        }
      }
      if (atLeastOneLoaded) {
        debugPrint('✅ [LocationBloc] Finished updating locations media to cloud');
        debugPrint('📥 [LocationBloc] Getting user data from cloud');
        await Future.delayed(const Duration(milliseconds: 2000));
        // ignore: use_build_context_synchronously
        _userBloc.add(GetUser(event.context));
        await for (final state in _userBloc.stream) {
          if (state is CurrentUser) {
            debugPrint('✅ [LocationBloc] User data loaded');
            break;
          } else if (state is NoCurrentUser && state.exception != null && state.isLoading == false) {
            debugPrint('❌ [LocationBloc] Failed to get user data: ${state.exception}');
            navigatorKey.currentState?.pushNamedAndRemoveUntil(Routes.splashRoute, (route) => false);
          }
        }
        debugPrint('📥 [LocationBloc] Getting locations from cloud');
        final completer = Completer<void>();
        final maxAttempts = 10;
        int attempts = 0;
        final subscription = stream.listen((state) async {
          if (state is LocationsLoaded && !completer.isCompleted) {
            for (final location in _cloudLocations) {
              if (_loadingStates[location.id] != LoadingState.uploaded) {
                continue;
              }
              if (location.media == null) {
                debugPrint('📥 [LocationBloc] Location ${location.id} media is null, attempt $attempts');
                attempts++;
                await Future.delayed(Duration(milliseconds: 200 * attempts));
                add(GetUserLocations(event.context));
                if (attempts >= maxAttempts) {
                  break;
                }
              }
            }
            completer.complete();
          }
        });

        add(GetUserLocations(event.context));

        await completer.future;
        await subscription.cancel();
      }

      _loadingStates = {..._loadingStates, 'cloud': LoadingState.loaded};
      debugPrint('🔍 [LocationBloc] Loading states: $_loadingStates');
      emit(LocationsLoaded(
        cloudLocations: _cloudLocations,
        localSavedLocations: _localSavedLocations,
        localUnsavedLocations: _localUnsavedLocations,
        loadingStates: _loadingStates,
        failedLocations: failedLocations,
      ));
    } catch (e) {
      debugPrint('❌ [LocationBloc] Failed to update locations media to cloud: ${e.toString()}');
      for (final location in event.locations) {
        _loadingStates = {
          ..._loadingStates,
          location.id: _loadingStates[location.id] == LoadingState.uploaded ? LoadingState.uploaded : LoadingState.error
        };
        if (_loadingStates[location.id] == LoadingState.error) {
          if (e is LivitException) {
            failedLocations[location] = {'error': e};
          } else {
            failedLocations[location] = {'error': GenericLocationBlocException()};
          }
        }
      }
      _loadingStates = {..._loadingStates, 'cloud': LoadingState.loaded};
      debugPrint('🔍 [LocationBloc] Loading states: $_loadingStates');
      emit(LocationsLoaded(
        cloudLocations: _cloudLocations,
        localSavedLocations: _localSavedLocations,
        localUnsavedLocations: _localUnsavedLocations,
        loadingStates: _loadingStates,
        failedLocations: failedLocations,
        errorMessage: e.toString(),
      ));
    } finally {
      _backgroundBloc.add(BackgroundStopLoadingAnimation());
    }
  }

  // Local Events

  Future<void> _onCreateLocationLocally(
    CreateLocationLocally event,
    Emitter<LocationState> emit,
  ) async {
    debugPrint('📝 [LocationBloc] Creating new location locally: ${event.location.name}');
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
    debugPrint('📝 [LocationBloc] Updating location locally: ${event.location.name}');
    _ensureInitialized();
    try {
      if (_localUnsavedLocations.isEmpty) {
        _localUnsavedLocations = _cloudLocations;
      }
      final LivitLocation oldLocation = _localUnsavedLocations.firstWhere(
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
      debugPrint('✅ [LocationBloc] Location updated locally successfully');
    } catch (e) {
      debugPrint('❌ [LocationBloc] Error updating location locally: $e');
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
    debugPrint('🗑️ [LocationBloc] Deleting location locally: ${event.location.name}');
    _ensureInitialized();
    _localUnsavedLocations = _localUnsavedLocations.where((location) => location.id != event.location.id).toList();
    for (var file in event.location.media?.files ?? <LivitMediaFile>[]) {
      MediaFileCleanup.cleanupLocationMediaFile(file);
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
    debugPrint('🖼️ [LocationBloc] Updating location media locally: ${event.location.name}');
    _ensureInitialized();

    if (_localUnsavedLocations.isEmpty) {
      if (_localSavedLocations.isEmpty) {
        _localUnsavedLocations = _cloudLocations.map((location) => location.copyWith()).toList();
      } else {
        _localUnsavedLocations = _localSavedLocations.map((location) => location.copyWith()).toList();
      }
    }

    final int oldUnsavedLocationIndex = _localUnsavedLocations.indexWhere((location) => location.id == event.location.id);
    final LivitLocationMedia? oldUnsavedLocationMedia = _localUnsavedLocations[oldUnsavedLocationIndex].media;
    late final LivitLocationMedia? oldSavedLocationMedia;
    try {
      oldSavedLocationMedia = _localSavedLocations
          .firstWhere((location) => location.id == event.location.id, orElse: () => throw Exception('No saved locations'))
          .media;
    } catch (_) {
      oldSavedLocationMedia = null;
    }
    final LivitLocationMedia? newLocationMedia = event.location.media;

    final List<String?> allOldUnsavedLocationMediaFilesPaths = oldUnsavedLocationMedia?.files?.map((file) => file?.filePath).toList() ?? [];

    final List<String?> allNewLocationMediaFilesPaths = newLocationMedia?.files?.map((file) => file?.filePath).toList() ?? [];

    final List<String?> allOldSavedLocationMediaFilesPaths = oldSavedLocationMedia?.files?.map((file) => file?.filePath).toList() ?? [];

    final List<String?> removedFilePaths =
        allOldUnsavedLocationMediaFilesPaths.where((path) => !allNewLocationMediaFilesPaths.contains(path)).toList();

    if (oldSavedLocationMedia != null) {
      final List<String?> filePathsToDelete = removedFilePaths.where((path) => !allOldSavedLocationMediaFilesPaths.contains(path)).toList();

      for (var filePath in filePathsToDelete) {
        debugPrint('🗑️ [LocationBloc] Deleting old saved location media file: $filePath');
        MediaFileCleanup.deleteFileByPath(filePath);
      }
    } else {
      for (var filePath in removedFilePaths) {
        debugPrint('🗑️ [LocationBloc] Deleting old unsaved location media file: $filePath');
        MediaFileCleanup.deleteFileByPath(filePath);
      }
    }

    _localUnsavedLocations[oldUnsavedLocationIndex] = _localUnsavedLocations[oldUnsavedLocationIndex].copyWith(media: event.media);

    emit(LocationsLoaded(
      cloudLocations: _cloudLocations,
      localSavedLocations: _localSavedLocations,
      localUnsavedLocations: _localUnsavedLocations,
      loadingStates: _loadingStates,
    ));
  }

  void _onSaveChangesLocally(
    SaveChangesLocally event,
    Emitter<LocationState> emit,
  ) async {
    if (_localUnsavedLocations.isEmpty) {
      debugPrint('💾 [LocationBloc] No unsaved locations');
      emit(LocationsLoaded(
        cloudLocations: _cloudLocations,
        localSavedLocations: _localSavedLocations,
        localUnsavedLocations: _localUnsavedLocations,
        loadingStates: _loadingStates,
      ));
      return;
    }
    debugPrint('💾 [LocationBloc] Saving changes locally');
    debugPrint('💾 [LocationBloc] Local unsaved locations: ${_localUnsavedLocations.map((location) => location.name)}');
    debugPrint('💾 [LocationBloc] Local saved locations: ${_localSavedLocations.map((location) => location.name)}');
    try {
      _ensureInitialized();
      List<String?> newFilePaths = [];
      for (var newLocation in _localUnsavedLocations) {
        newFilePaths.addAll([
          ...?newLocation.media?.files?.map((file) => file?.filePath),
          ...?newLocation.media?.files?.map((file) => (file is LivitMediaVideo) ? file.cover.filePath : null),
        ]);
      }
      List<String?> oldFilePaths = [];
      for (var oldSavedlocation in _localSavedLocations) {
        oldFilePaths.addAll([
          ...?oldSavedlocation.media?.files?.map((file) => file?.filePath),
          ...?oldSavedlocation.media?.files?.map((file) => (file is LivitMediaVideo) ? file.cover.filePath : null),
        ]);
      }

      List<String?> filePathsToDelete = oldFilePaths.where((path) => !newFilePaths.contains(path)).toList();

      for (var filePath in filePathsToDelete) {
        MediaFileCleanup.deleteFileByPath(filePath);
      }

      _localSavedLocations = _localUnsavedLocations;

      _localUnsavedLocations = [];
      debugPrint('✅ [LocationBloc] Saved changes locally');
      emit(LocationsLoaded(
        cloudLocations: _cloudLocations,
        localSavedLocations: _localSavedLocations,
        localUnsavedLocations: _localUnsavedLocations,
        loadingStates: _loadingStates,
      ));
    } catch (e) {
      debugPrint('❌ [LocationBloc] Failed to save changes locally: $e');
      emit(LocationsLoaded(
        cloudLocations: _cloudLocations,
        localSavedLocations: _localSavedLocations,
        localUnsavedLocations: _localUnsavedLocations,
        loadingStates: _loadingStates,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onDiscardChangesLocally(
    DiscardChangesLocally event,
    Emitter<LocationState> emit,
  ) async {
    debugPrint('🔄 [LocationBloc] Discarding local changes');
    List<String?> newFilePaths = [];
    for (var newLocation in _localUnsavedLocations) {
      newFilePaths.addAll([
        ...?newLocation.media?.files?.map((file) => file?.filePath),
        ...?newLocation.media?.files?.map((file) => (file is LivitMediaVideo) ? file.cover.filePath : null),
      ]);
    }
    List<String?> oldFilePaths = [];
    for (var oldSavedlocation in _localSavedLocations) {
      oldFilePaths.addAll([
        ...?oldSavedlocation.media?.files?.map((file) => file?.filePath),
        ...?oldSavedlocation.media?.files?.map((file) => (file is LivitMediaVideo) ? file.cover.filePath : null),
      ]);
    }

    List<String?> filePathsToDelete = newFilePaths.where((path) => !oldFilePaths.contains(path)).toList();

    for (var filePath in filePathsToDelete) {
      MediaFileCleanup.deleteFileByPath(filePath);
    }

    _localUnsavedLocations = [];
    emit(LocationsLoaded(
      cloudLocations: _cloudLocations,
      localSavedLocations: _localSavedLocations,
      localUnsavedLocations: _localUnsavedLocations,
      loadingStates: _loadingStates,
    ));
  }

  void _onSetCurrentLocation(
    SetCurrentLocation event,
    Emitter<LocationState> emit,
  ) async {
    debugPrint('🛠️ [LocationBloc] Setting current location: ${event.locationId}');
    currentLocation = _cloudLocations.firstWhere((location) => location.id == event.locationId);
    emit(LocationsLoaded(
      cloudLocations: _cloudLocations,
      localSavedLocations: _localSavedLocations,
      localUnsavedLocations: _localUnsavedLocations,
      loadingStates: _loadingStates,
    ));
  }

  Map<String, bool> isLocationValid(LivitLocation location) {
    final bool isNameValid = location.name != '' && location.name.isNotEmpty && location.name.length < 30;

    final bool isAddressValid = location.address != '' && location.address.isNotEmpty && location.address.length < 50;

    final bool isDepartmentValid = location.state != '' && location.state.isNotEmpty;

    final bool isCityValid = location.city != '' && location.city.isNotEmpty;

    final bool isDescriptionValid = (location.description?.length ?? 0) <= 100;

    final bool isMediaValid = location.media?.files?.isNotEmpty ?? false;

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

  bool get areAllLocationsValid => locations.every((location) => isLocationValid(location)['isValid'] as bool);

  bool get areAllLocationsValidWithoutMedia => locations.every((location) => isLocationValid(location)['isValidWithoutMedia'] as bool);
}
