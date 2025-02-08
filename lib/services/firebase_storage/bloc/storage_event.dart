import 'package:livit/models/location/location.dart';

abstract class StorageEvent {
  const StorageEvent();
}

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

class GetMediaFile extends StorageEvent {
  final String url;

  const GetMediaFile({required this.url});
}

