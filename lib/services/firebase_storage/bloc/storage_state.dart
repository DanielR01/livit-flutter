import 'dart:io';

import 'package:livit/cloud_models/location/location_media.dart';
import 'package:livit/services/exceptions/base_exception.dart';
import 'package:livit/services/firebase_storage/bloc/storage_bloc_exception.dart';

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

class StorageDownloading extends StorageState {
  final double progress;
  const StorageDownloading({this.progress = 0.0});
}

class StorageDownloaded extends StorageState {
  final List<String> urls;
  const StorageDownloaded({required this.urls});
}

class StorageUploaded extends StorageState {
  final LivitLocationMedia media;
  const StorageUploaded({required this.media});
}

class StorageSignedUrlsObtained extends StorageState {
  final LivitLocationMedia media;
  const StorageSignedUrlsObtained({required this.media});
}

class StorageFailure extends StorageState {
  final LivitException exception;
  const StorageFailure({required this.exception});
}
