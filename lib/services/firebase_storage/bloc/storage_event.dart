import 'dart:io';

abstract class StorageEvent {
  const StorageEvent();
}

class UploadLocationMedia extends StorageEvent {
  final String locationId;
  final List<File> files;
  final String type; // 'images' or 'videos'

  const UploadLocationMedia({
    required this.locationId,
    required this.files,
    required this.type,
  });
}
