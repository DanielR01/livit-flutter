import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/models/event/event.dart';
import 'package:livit/services/background/background_bloc.dart';
import 'package:livit/services/background/background_events.dart';
import 'package:livit/services/cloud_functions/firestore_cloud_functions.dart';
import 'package:livit/services/error_reporting/error_reporter.dart';
import 'package:livit/services/firebase_storage/bloc/storage_bloc.dart';
import 'package:livit/services/firebase_storage/bloc/storage_event.dart' as storage_event;
import 'package:livit/services/firebase_storage/bloc/storage_state.dart';
import 'package:livit/services/firestore_storage/bloc/event/event_event.dart';
import 'package:livit/services/firestore_storage/bloc/event/event_state.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/user/user_bloc.dart';
import 'package:livit/services/firestore_storage/firestore_storage/firestore_storage.dart';
import 'package:livit/utilities/debug/livit_debugger.dart';

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final FirestoreStorageService _storageService;
  final UserBloc _userBloc;
  final BackgroundBloc _backgroundBloc;
  final FirestoreCloudFunctions _cloudFunctions;
  final StorageBloc _storageBloc;
  final LocationBloc _locationBloc;
  final ErrorReporter _errorReporter = ErrorReporter(viewName: 'EventsBloc');
  final _debugger = LivitDebugger('EventsBloc', isDebugEnabled: true);

  Map<String, LoadingState> _loadingStates = {};
  final Map<EventViewType, Map<String, List<LivitEvent>>> _loadedEvents = {
    EventViewType.feed: {},
    EventViewType.location: {},
  };

  EventsBloc({
    required FirestoreStorageService storageService,
    required UserBloc userBloc,
    required BackgroundBloc backgroundBloc,
    required FirestoreCloudFunctions cloudFunctions,
    required StorageBloc storageBloc,
    required LocationBloc locationBloc,
  })  : _storageService = storageService,
        _userBloc = userBloc,
        _backgroundBloc = backgroundBloc,
        _cloudFunctions = cloudFunctions,
        _storageBloc = storageBloc,
        _locationBloc = locationBloc,
        super(EventsInitial()) {
    on<FetchNextEventsByLocation>(_onFetchNextEventsByLocation);
    on<RefreshEventsByLocation>(_onRefreshEventsByLocation);
    on<CreateEvent>(_onCreateEvent);
    on<SetEventMedia>(_onSetEventMedia);
  }

  Future<void> _onFetchNextEventsByLocation(FetchNextEventsByLocation event, Emitter<EventsState> emit) async {
    try {
      _loadingStates = {..._loadingStates, event.locationId: LoadingState.loading};
      emit(EventsLoaded(loadedEvents: _loadedEvents, loadingStates: _loadingStates));
      _backgroundBloc.add(BackgroundStartLoadingAnimation());
      final Iterable<LivitEvent> nextEvents = await _storageService.eventService.getNextEventsByLocation(locationId: event.locationId);
      _loadingStates = {..._loadingStates, event.locationId: LoadingState.loaded};
      _loadedEvents[EventViewType.location]![event.locationId] ??= [];
      _loadedEvents[EventViewType.location]![event.locationId]!.addAll(nextEvents);
      emit(EventsLoaded(loadedEvents: _loadedEvents, loadingStates: _loadingStates));
    } catch (e) {
      _debugger.debPrint('Error fetching events by location: $e', DebugMessageType.error);
      emit(EventsError(message: e.toString()));
    } finally {
      _backgroundBloc.add(BackgroundStopLoadingAnimation());
    }
  }

  Future<void> _onRefreshEventsByLocation(RefreshEventsByLocation event, Emitter<EventsState> emit) async {
    _debugger.debPrint('Refreshing events by location', DebugMessageType.request);

    // Clear all existing data
    _loadingStates = {};
    _loadedEvents[EventViewType.location]!.clear();
    _loadedEvents[EventViewType.feed]!.clear();

    // Emit the empty state first
    emit(EventsLoaded(loadedEvents: _loadedEvents, loadingStates: _loadingStates));

    // Fetch events for all previously known locations
    final locationId = _locationBloc.currentLocation?.id;
    if (locationId != null) {
      _debugger.debPrint('After refresh, fetching events for location: $locationId', DebugMessageType.request);
      final fetchEvent = FetchNextEventsByLocation(locationId: locationId);
      await _onFetchNextEventsByLocation(fetchEvent, emit);
    }
  
  }

  Future<void> _onCreateEvent(CreateEvent event, Emitter<EventsState> emit) async {
    try {
      _debugger.debPrint('Creating event: ${event.event.name}', DebugMessageType.creating);
      emit(EventCreating(event: event.event));

      _backgroundBloc.add(BackgroundStartLoadingAnimation());

      final String promoterId = _userBloc.currentUser?.id ?? '';

      final eventWithPromoterId = event.event.copyWith(promoterIds: [promoterId]);

      final String eventId = await _cloudFunctions.createEvent(event: eventWithPromoterId);

      _debugger.debPrint('Event created successfully with ID: $eventId', DebugMessageType.done);

      emit(EventCreated(event: event.event, eventId: eventId));
      emit(EventsLoaded(loadedEvents: _loadedEvents, loadingStates: _loadingStates));
    } catch (e) {
      _debugger.debPrint('Error creating event: $e', DebugMessageType.error);
      _errorReporter.reportError(e, StackTrace.current);
      emit(EventCreationError(message: e.toString(), event: event.event));
    } finally {
      _backgroundBloc.add(BackgroundStopLoadingAnimation());
    }
  }

  Future<void> _onSetEventMedia(SetEventMedia event, Emitter<EventsState> emit) async {
    try {
      _debugger.debPrint('Setting event media for: ${event.event.id}', DebugMessageType.updating);
      _debugger.debPrint('Event media count: ${event.event.media.media.length}', DebugMessageType.info);
      emit(EventUpdating(event: event.event));
      _backgroundBloc.add(BackgroundStartLoadingAnimation());

      // Verify media with StorageBloc
      _debugger.debPrint('Starting media verification process', DebugMessageType.verifying);
      _storageBloc.add(storage_event.VerifyEventMedia(event: event.event));

      // Wait for StorageBloc to complete verification
      _debugger.debPrint('Waiting for media verification to complete', DebugMessageType.waiting);
      await _waitForStorageState(
          expectedState: LoadingState.verified, expectedId: event.event.id, errorMessage: 'Failed to verify event media');
      _debugger.debPrint('Media verification completed successfully', DebugMessageType.done);

      // If verified, delete any existing media
      _debugger.debPrint('Starting deletion of existing media', DebugMessageType.deleting);
      _storageBloc.add(storage_event.DeleteEventMedia(eventId: event.event.id));

      // Wait for StorageBloc to complete deletion
      _debugger.debPrint('Waiting for media deletion to complete', DebugMessageType.waiting);
      await _waitForStorageState(
          expectedState: LoadingState.deleted,
          expectedId: event.event.id,
          errorMessage: 'Failed to delete existing event media',
          maxAttempts: 100);
      _debugger.debPrint('Media deletion completed successfully', DebugMessageType.done);

      // Upload new media
      _debugger.debPrint('Starting upload of new media files', DebugMessageType.uploading);
      _storageBloc.add(const storage_event.SetEventMedia());

      // Wait for StorageBloc to complete uploading
      _debugger.debPrint('Waiting for media upload to complete', DebugMessageType.waiting);
      await _waitForStorageState(
        expectedState: LoadingState.uploaded,
        expectedId: event.event.id,
        errorMessage: 'Failed to upload event media',
        maxAttempts: 300,
      );
      _debugger.debPrint('Media upload completed successfully', DebugMessageType.done);

      _debugger.debPrint('Event media updated successfully', DebugMessageType.done);
      emit(EventUpdated(event: event.event));
      emit(EventsLoaded(loadedEvents: _loadedEvents, loadingStates: _loadingStates));
    } catch (e) {
      _debugger.debPrint('Error setting event media: $e', DebugMessageType.error);
      _debugger.debPrint('Stack trace: ${StackTrace.current}', DebugMessageType.error);
      _errorReporter.reportError(e, StackTrace.current);
      emit(EventUpdateError(message: e.toString(), event: event.event));
    } finally {
      _backgroundBloc.add(BackgroundStopLoadingAnimation());
      _debugger.debPrint('Event media operation completed (success or failure)', DebugMessageType.info);
    }
  }

  Future<void> _waitForStorageState({
    required LoadingState expectedState,
    required String expectedId,
    required String errorMessage,
    int maxAttempts = 30,
    Duration pollInterval = const Duration(milliseconds: 300),
  }) async {
    int attempts = 0;
    bool success = false;

    _debugger.debPrint('Starting wait for storage state: $expectedState for ID: $expectedId', DebugMessageType.waiting);
    _debugger.debPrint('Max attempts: $maxAttempts, Poll interval: ${pollInterval.inMilliseconds}ms', DebugMessageType.info);

    while (attempts < maxAttempts && !success) {
      final currentState = _storageBloc.state;
      attempts++;

      if (currentState is StorageLoaded) {
        final currentLoadingState = currentState.loadingStates[expectedId];

        if (attempts % 10 == 0) {
          _debugger.debPrint('Attempt $attempts - Current state: $currentLoadingState, Expected: $expectedState', DebugMessageType.waiting);
        }

        if (currentLoadingState == expectedState) {
          success = true;
          _debugger.debPrint('Expected state reached after $attempts attempts', DebugMessageType.done);
          break;
        } else if (currentLoadingState == LoadingState.error) {
          String detailedError = '';

          if (currentState.exceptions != null && currentState.exceptions![expectedId] != null) {
            detailedError = currentState.exceptions![expectedId]!.values.map((e) => e.message).join(', ');
          }

          _debugger.debPrint('Error state detected: $detailedError', DebugMessageType.error);
          throw Exception('$errorMessage: $detailedError');
        }
      } else {
        _debugger.debPrint('StorageBloc state is not StorageLoaded: ${currentState.runtimeType}', DebugMessageType.warning);
      }

      await Future.delayed(pollInterval);
    }

    if (!success) {
      _debugger.debPrint('Timeout waiting for storage state after $attempts attempts', DebugMessageType.error);
      throw Exception('$errorMessage: Timeout waiting for operation to complete');
    }
  }
}
