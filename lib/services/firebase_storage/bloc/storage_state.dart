import 'dart:io';

abstract class StorageState {
  const StorageState();
}

class StorageInitial extends StorageState {
  const StorageInitial();
}

class StorageUploading extends StorageState {
  final double progress;
  const StorageUploading({this.progress = 0.0});
}

class StorageSuccess extends StorageState {
  final List<String> urls;
  final List<File>? failedFiles;
  const StorageSuccess({required this.urls, this.failedFiles});
}

class StorageFailure extends StorageState {
  final Exception exception;
  const StorageFailure({required this.exception});
}
