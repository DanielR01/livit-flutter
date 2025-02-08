abstract class EventsEvent {}

class FetchInitialEvents extends EventsEvent {}

class FetchMoreEvents extends EventsEvent {}

class FetchNextEventsByLocation extends EventsEvent {
  final String locationId;

  FetchNextEventsByLocation({required this.locationId});
}

class RefreshEvents extends EventsEvent {}
