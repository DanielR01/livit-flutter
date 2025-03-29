abstract class StorageReference {
  final StorageReferenceType type;

  StorageReference({required this.type});
}

class LocationMediaStorageReference extends StorageReference {
  final String locationId;
  LocationMediaStorageReference({required this.locationId, super.type = StorageReferenceType.location});
}

class EventMediaStorageReference extends StorageReference {
  final String eventId;
  final String index;

  EventMediaStorageReference({required this.eventId, required this.index, super.type = StorageReferenceType.event});
}

enum StorageReferenceType {
  location,
  user,
  event,
  ticket,
  product,
}
