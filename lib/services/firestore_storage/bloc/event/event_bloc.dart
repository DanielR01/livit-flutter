import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/models/event/event.dart';
import 'package:livit/services/background/background_bloc.dart';
import 'package:livit/services/background/background_events.dart';
import 'package:livit/services/firestore_storage/bloc/event/event_event.dart';
import 'package:livit/services/firestore_storage/bloc/event/event_state.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_bloc.dart';
import 'package:livit/services/firestore_storage/firestore_storage/firestore_storage.dart';

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final FirestoreStorageService _storageService;
  final LocationBloc _locationBloc;
  final BackgroundBloc _backgroundBloc;

  Map<String, LoadingState> _loadingStates = {};
  final Map<EventViewType, Map<String, List<LivitEvent>>> _loadedEvents = {
    EventViewType.feed: {},
    EventViewType.location: {},
  };

  EventsBloc({
    required FirestoreStorageService storageService,
    required LocationBloc locationBloc,
    required BackgroundBloc backgroundBloc,
  })  : _storageService = storageService,
        _locationBloc = locationBloc,
        _backgroundBloc = backgroundBloc,
        super(EventsInitial()) {
    on<FetchNextEventsByLocation>(_onFetchNextEventsByLocation);
    on<RefreshEvents>(_onRefreshEvents);
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
      emit(EventsError(message: e.toString()));
    } finally {
      _backgroundBloc.add(BackgroundStopLoadingAnimation());
    }
  }

  Future<void> _onRefreshEvents(RefreshEvents event, Emitter<EventsState> emit) async {
    _loadingStates = {};
    _loadedEvents[EventViewType.location]!.clear();
    _loadedEvents[EventViewType.feed]!.clear();
    emit(EventsLoaded(loadedEvents: _loadedEvents, loadingStates: _loadingStates));
  }
}
