import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livit/services/firestore_storage/livit_event.dart';

abstract class EventsState {}

class EventsInitial extends EventsState {}

class EventsLoading extends EventsState {}

class EventsLoaded extends EventsState {
  final List<LivitEvent> events;
  final bool hasMore;
  final DocumentSnapshot<LivitEvent>? lastDocument;

  EventsLoaded({
    required this.events,
    required this.hasMore,
    this.lastDocument,
  });
}

class EventsError extends EventsState {
  final String message;

  EventsError({required this.message});
}