import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/events/events_event.dart';
import 'package:livit/services/firestore_storage/bloc/events/events_state.dart';
import 'package:livit/services/firestore_storage/bloc/firestore_storage/firestore_storage.dart';

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final FirestoreStorage _storage;
  final String creatorId;
  static const int _limit = 10;

  EventsBloc({required FirestoreStorage storage, required this.creatorId})
      : _storage = storage,
        super(EventsInitial()) {
    on<FetchInitialEvents>(_onFetchInitialEvents);
    on<FetchMoreEvents>(_onFetchMoreEvents);
  }

  Future<void> _onFetchInitialEvents(FetchInitialEvents event, Emitter<EventsState> emit) async {
    emit(EventsLoading());
    try {
      final events = await _storage.getEventsPaginated(
        creatorId: creatorId,
        limit: _limit,
      );
      final hasMore = events.events.length == _limit;
      final lastDocument = hasMore ? events.lastDocument : null;
      emit(EventsLoaded(
        events: events.events,
        hasMore: hasMore,
        lastDocument: lastDocument,
      ));
    } catch (e) {
      emit(EventsError(message: e.toString()));
    }
  }

  Future<void> _onFetchMoreEvents(FetchMoreEvents event, Emitter<EventsState> emit) async {
    final currentState = state;
    if (currentState is EventsLoaded && currentState.hasMore) {
      try {
        final newEvents = await _storage.getEventsPaginated(
          creatorId: creatorId,
          limit: _limit,
          startAfterDoc: currentState.lastDocument,
        );
        final hasMore = newEvents.events.length == _limit;
        final lastDocument = hasMore ? newEvents.lastDocument : null;

        emit(
          EventsLoaded(
            events: currentState.events + newEvents.events,
            hasMore: hasMore,
            lastDocument: lastDocument,
          ),
        );
      } catch (e) {
        emit(EventsError(message: e.toString()));
      }
    }
  }
}
