class CloudStorageException implements Exception {
  const CloudStorageException();
}

class CouldNotCreateEventException extends CloudStorageException {}

class CouldNotGetAllEventsException extends CloudStorageException {}

class CouldNotUpdateEventException extends CloudStorageException {}

class CouldNotDeleteEventException extends CloudStorageException {}
