import 'package:livit/cloud_models/location/location_media.dart';

abstract class StorageEvent {
  const StorageEvent();
}

class SetLocationMedia extends StorageEvent {
  const SetLocationMedia();
}

class GetSignedUrls extends StorageEvent {
  final String locationId;
  final LivitLocationMedia media;

  const GetSignedUrls({required this.locationId, required this.media});
}

class DeleteLocationMedia extends StorageEvent {
  final String locationId;
  const DeleteLocationMedia({required this.locationId});
}
