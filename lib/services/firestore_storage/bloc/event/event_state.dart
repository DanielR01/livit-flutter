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