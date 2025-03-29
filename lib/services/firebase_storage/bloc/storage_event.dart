import 'package:livit/models/location/location.dart';
import 'package:livit/models/event/event.dart';

abstract class StorageEvent {
  const StorageEvent();
}

// Location media events
class VerifyLocationMedia extends StorageEvent {
  final LivitLocation location;
  const VerifyLocationMedia({required this.location});
}

class SetLocationMedia extends StorageEvent {
  const SetLocationMedia();
}

class DeleteLocationMedia extends StorageEvent {
  final String locationId;
  const DeleteLocationMedia({required this.locationId});
}

// Event media events
class VerifyEventMedia extends StorageEvent {
  final LivitEvent event;
  const VerifyEventMedia({required this.event});
}

class SetEventMedia extends StorageEvent {
  const SetEventMedia();
}

class DeleteEventMedia extends StorageEvent {
  final String eventId;
  const DeleteEventMedia({required this.eventId});
}

class GetMediaFile extends StorageEvent {
  final String url;

  const GetMediaFile({required this.url});
}
