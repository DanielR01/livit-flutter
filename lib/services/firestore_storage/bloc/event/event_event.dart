import 'package:flutter/material.dart';
import 'package:livit/models/event/event.dart';

abstract class EventsEvent {}

class FetchInitialEvents extends EventsEvent {}

class FetchMoreEvents extends EventsEvent {}

class FetchNextEventsByLocation extends EventsEvent {
  final String locationId;

  FetchNextEventsByLocation({required this.locationId});
}

class RefreshEvents extends EventsEvent {}

class CreateEvent extends EventsEvent {
  final LivitEvent event;
  

  CreateEvent({required this.event});
}

class SetEventMedia extends EventsEvent {
  final LivitEvent event;
  final BuildContext context;

  SetEventMedia({required this.event, required this.context});
}
