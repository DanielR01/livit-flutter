abstract class StorageReference {
  final StorageReferenceType type;

  StorageReference({required this.type});
}

class LocationMediaStorageReference extends StorageReference {
  final String locationId;
  LocationMediaStorageReference({required this.locationId, super.type = StorageReferenceType.location});
}

enum StorageReferenceType {
  location,
  user,
  event,
  ticket,
  product,
}