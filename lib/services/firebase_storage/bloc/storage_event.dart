import 'package:livit/cloud_models/location/location_media.dart';

abstract class StorageEvent {
  const StorageEvent();
}

class SetLocationMedia extends StorageEvent {
  final String locationId;
  final LivitLocationMedia media;

  const SetLocationMedia({
    required this.locationId,
    required this.media,
  });
}
