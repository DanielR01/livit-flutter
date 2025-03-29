import 'package:livit/constants/enums.dart';
import 'package:livit/models/event/event.dart';

enum EventViewType {
  feed,
  location,
}

abstract class EventsState {}

class EventsInitial extends EventsState {}

class EventsLoaded extends EventsState {
  final Map<EventViewType, Map<String, List<LivitEvent>>> loadedEvents;
  final Map<String, LoadingState> loadingStates;
  final Map<String, String>? errorMessages;

  EventsLoaded({required this.loadedEvents, required this.loadingStates, this.errorMessages});
}

class EventsError extends EventsState {
  final String message;

  EventsError({required this.message});
}

class EventCreating extends EventsState {
  final LivitEvent event;

  EventCreating({required this.event});
}

class EventCreated extends EventsState {
  final LivitEvent event;
  final String eventId;

  EventCreated({required this.event, required this.eventId});
}

class EventCreationError extends EventsState {
  final String message;
  final LivitEvent event;

  EventCreationError({required this.message, required this.event});
}

class EventUpdating extends EventsState {
  final LivitEvent event;

  EventUpdating({required this.event});
}

class EventUpdated extends EventsState {
  final LivitEvent event;

  EventUpdated({required this.event});
}

class EventUpdateError extends EventsState {
  final String message;
  final LivitEvent event;

  EventUpdateError({required this.message, required this.event});
}
