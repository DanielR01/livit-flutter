import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/cloud_models/location/location_media.dart';
import 'package:livit/cloud_models/location/location_media_file.dart';
import 'package:livit/services/error_reporting/error_reporter.dart';
import 'package:livit/services/exceptions/base_exception.dart';
import 'package:livit/services/firebase_storage/bloc/storage_bloc_exception.dart';
import 'package:livit/services/firebase_storage/bloc/storage_event.dart';
import 'package:livit/services/firebase_storage/bloc/storage_state.dart';
import 'package:livit/services/firebase_storage/firebase_storage_constants.dart';
import 'package:livit/services/firebase_storage/storage_service/storage_service.dart';
import 'package:livit/services/firebase_storage/storage_service/storage_service_exceptions.dart';
import 'package:livit/services/firestore_storage/cloud_functions/cloud_functions_exceptions.dart';
import 'package:livit/services/firestore_storage/cloud_functions/firestore_cloud_functions.dart';
import 'package:livit/utilities/media/media_file_cleanup.dart';

class StorageBloc extends Bloc<StorageEvent, StorageState> {
  final StorageService _storageService;
  final FirestoreCloudFunctions _cloudFunctions;
  List<String> _signedUrls = [];
  List<Map<String, dynamic>> _fileProperties = [];
  List<String> _filePaths = [];
  List<Timestamp> _timestamps = [];
  List<String> _names = [];
  LivitLocationMedia? _mediaToUpload;
  String? _locationId;

  StorageBloc({
    required StorageService storageService,
    required FirestoreCloudFunctions cloudFunctions,
  })  : _storageService = storageService,
        _cloudFunctions = cloudFunctions,
        super(const StorageInitial()) {
    on<GetSignedUrls>(_onGetSignedUrls);
    on<SetLocationMedia>(_onSetLocationMedia);
    on<DeleteLocationMedia>(_onDeleteLocationMedia);
  }
  Future<void> _onGetSignedUrls(
    GetSignedUrls event,
    Emitter<StorageState> emit,
  ) async {
    emit(const StorageGettingSignedUrls());
    final List<String> names = [];
    try {
      if (event.media.mainFile?.filePath == null) {
        throw GenericStorageBlocException(details: 'Location ${event.locationId} has no main file');
      }
      if (event.media.mainFile is LivitLocationMediaVideo) {
        names.add('main_file/cover.${(event.media.mainFile! as LivitLocationMediaVideo).cover.filePath!.split('.').last}');
        names.add('main_file/video.${event.media.mainFile!.filePath!.split('.').last}');
      } else {
        names.add('main_file/image.${event.media.mainFile!.filePath!.split('.').last}');
      }
      debugPrint('🔍 [StorageBloc] Verifying ${1 + (event.media.secondaryFiles?.length ?? 0)} files');
      List<Map<String, dynamic>> fileProperties = await _isFileValid(event.media.mainFile!);
      if (event.media.secondaryFiles != null && event.media.secondaryFiles!.isNotEmpty) {
        for (final file in event.media.secondaryFiles!) {
          final index = event.media.secondaryFiles!.indexOf(file);
          if (file == null) continue;
          if (file is LivitLocationMediaVideo) {
            names.add('secondary_files/index_$index/cover.${file.filePath!.split('.').last}');
            names.add('secondary_files/index_$index/video.${file.filePath!.split('.').last}');
          } else {
            names.add('secondary_files/index_$index/image.${file.filePath!.split('.').last}');
          }
          fileProperties.addAll(await _isFileValid(file));
        }
      }
      debugPrint('📑 [StorageBloc] File properties: $fileProperties');
      debugPrint('📑 [StorageBloc] Media names: $names');
      debugPrint('📞 [StorageBloc] Calling getLocationMediaUploadUrls function');
      final response = await _cloudFunctions.getLocationMediaUploadUrls(
        locationId: event.locationId,
        fileSizes: fileProperties.map((e) => e['size'] as int).toList(),
        fileTypes: fileProperties.map((e) => e['type'] as String).toList(),
        names: names,
      );
      final List<String> signedUrls = response['signedUrls'] as List<String>;
      final List<Timestamp> timestamps = response['timestamps'] as List<Timestamp>;
      debugPrint('📥 [StorageBloc] Obtained ${signedUrls.length} signed URLs');
      debugPrint('📥 [StorageBloc] Timestamps: $timestamps');
      if (signedUrls.length != fileProperties.length) {
        throw GenericStorageBlocException(details: 'Signed URLs length does not match file sizes length');
      }
      if (event.media.mainFile is LivitLocationMediaVideo) {
        _filePaths = [(event.media.mainFile! as LivitLocationMediaVideo).cover.filePath!, event.media.mainFile!.filePath!];
      } else {
        _filePaths = [event.media.mainFile!.filePath!];
      }
      if (event.media.secondaryFiles != null && event.media.secondaryFiles!.isNotEmpty) {
        for (final file in event.media.secondaryFiles!) {
          if (file is LivitLocationMediaVideo) {
            _filePaths.add(file.cover.filePath!);
            _filePaths.add(file.filePath!);
          } else {
            _filePaths.add(file!.filePath!);
          }
        }
      }
      _timestamps = timestamps;
      _signedUrls = signedUrls;
      _fileProperties = fileProperties;
      _mediaToUpload = event.media;
      _locationId = event.locationId;
      _names = names;
      emit(StorageSignedUrlsObtained());
    } on StorageBlocException catch (e) {
      _cleanData();
      debugPrint('❌ [StorageBloc] StorageBlocException on getSignedUrls: $e');
      emit(StorageFailure(exception: e));
    } on CloudFunctionException catch (e) {
      _cleanData();
      debugPrint('❌ [StorageBloc] CloudFunctionException on getSignedUrls: $e');
      emit(StorageFailure(exception: e));
    } catch (e) {
      _cleanData();
      final error = GenericStorageBlocException(details: e.toString());
      debugPrint('❌ [StorageBloc] Unknown error on getSignedUrls: $e');
      ErrorReporter().reportError(error, StackTrace.current);
      emit(StorageFailure(exception: error));
    }
  }

  Future<void> _onDeleteLocationMedia(
    DeleteLocationMedia event,
    Emitter<StorageState> emit,
  ) async {
    emit(const StorageDeleting());
    try {
      debugPrint('📞 [StorageBloc] Calling deleteOldLocationMedia');
      await _storageService.deleteLocationMedia(event.locationId);
      debugPrint('✅ [StorageBloc] Calling deleteOldLocationMedia done');
      emit(const StorageDeleted());
    } catch (e) {
      if (e is ObjectNotFoundStorageException) {
        debugPrint('✅ [StorageBloc] Object not found, deleting location media done');
        emit(const StorageDeleted());
        return;
      }
      debugPrint('❌ [StorageBloc] Error deleting location media: $e');
      emit(StorageFailure(exception: GenericStorageBlocException(details: e.toString())));
    }
  }

  Future<void> _onSetLocationMedia(
    SetLocationMedia event,
    Emitter<StorageState> emit,
  ) async {
    emit(StorageUploading());
    List<String> uploadedUrls = [];
    try {
      debugPrint('📑 [StorageBloc] Files to upload: ${_filePaths.length}');
      int filesUploaded = 0;
      int signedUrlsUsed = 0;
      if (_filePaths.isEmpty || _filePaths.any((e) => !File(e).existsSync()) || _mediaToUpload?.mainFile == null) {
        throw GenericStorageBlocException(details: 'No file paths to upload');
      }
      if (_timestamps.isEmpty || _timestamps.length != _signedUrls.length) {
        throw GenericStorageBlocException(details: 'Timestamps length does not match signed URLs length');
      }
      if (_timestamps.any((timestamp) => timestamp.toDate().difference(DateTime.now()).inSeconds < 90)) {
        throw GenericStorageBlocException(details: 'Signed URLs expired');
      }
      LivitLocationMedia newMedia = _mediaToUpload!.copyWith();
      while (signedUrlsUsed < _signedUrls.length) {
        if (_timestamps[signedUrlsUsed].toDate().difference(DateTime.now()).inSeconds < 20) {
          try {
            final response = await _cloudFunctions.getLocationMediaUploadUrls(
              locationId: _locationId!,
              fileSizes: [_fileProperties[signedUrlsUsed]['size'] as int],
              fileTypes: [_fileProperties[signedUrlsUsed]['type'] as String],
              names: [_names[signedUrlsUsed]],
            );
            _signedUrls[signedUrlsUsed] = response['signedUrls']![0];
            _timestamps[signedUrlsUsed] = response['timestamps']![0];
          } catch (e) {
            throw GenericStorageBlocException(details: 'Error getting signed URL after expiration: $e');
          }
        }
        final LivitLocationMediaFile fileToUpload =
            filesUploaded == 0 ? _mediaToUpload!.mainFile! : _mediaToUpload!.secondaryFiles![filesUploaded - 1]!;
        if (fileToUpload is LivitLocationMediaVideo) {
          final String coverUrl = await _uploadFile(fileToUpload.cover, _signedUrls[signedUrlsUsed], _fileProperties[signedUrlsUsed]);
          signedUrlsUsed++;
          final String videoUrl = await _uploadFile(fileToUpload, _signedUrls[signedUrlsUsed], _fileProperties[signedUrlsUsed]);
          signedUrlsUsed++;
          if (filesUploaded == 0) {
            newMedia = newMedia.copyWith(mainFile: fileToUpload.cover.copyWith(url: coverUrl, filePath: null));
            newMedia = newMedia.copyWith(mainFile: fileToUpload.copyWith(url: videoUrl, filePath: null));
          } else {
            newMedia = newMedia.copyWith(
                secondaryFiles: newMedia.secondaryFiles?.map((e) {
              if (e is LivitLocationMediaVideo && e == fileToUpload) {
                LivitLocationMediaImage newFileCover = fileToUpload.cover.copyWith(url: coverUrl, filePath: null);
                return LivitLocationMediaVideo(url: videoUrl, filePath: null, cover: newFileCover);
              }
              return e;
            }).toList());
          }
          uploadedUrls.add(coverUrl);
          uploadedUrls.add(videoUrl);
        } else {
          final String imageUrl = await _uploadFile(fileToUpload, _signedUrls[signedUrlsUsed], _fileProperties[signedUrlsUsed]);
          signedUrlsUsed++;
          uploadedUrls.add(imageUrl);
          if (filesUploaded == 0) {
            newMedia = newMedia.copyWith(mainFile: fileToUpload.copyWith(url: imageUrl, filePath: null));
          } else {
            newMedia = newMedia.copyWith(
                secondaryFiles: newMedia.secondaryFiles?.map((e) {
              if (e == fileToUpload) {
                return fileToUpload.copyWith(url: imageUrl, filePath: null);
              }
              return e;
            }).toList());
          }
        }
        MediaFileCleanup.cleanupLocationMediaFile(fileToUpload);
        filesUploaded++;
      }
      debugPrint('📥 [StorageBloc] Uploaded ${uploadedUrls.length} files');
      emit(StorageUploaded(media: newMedia));
    } on StorageBlocException catch (e) {
      debugPrint('❌ [StorageBloc] StorageBlocException: $e');
      await _deleteUploadedFiles(uploadedUrls);
      emit(StorageFailure(exception: e));
    } on CloudFunctionException catch (e) {
      debugPrint('❌ [StorageBloc] CloudFunctionException: $e');
      await _deleteUploadedFiles(uploadedUrls);
      emit(StorageFailure(exception: e));
    } catch (e) {
      final error = GenericStorageBlocException(details: e.toString());
      debugPrint('❌ [StorageBloc] Unknown error: $e');
      ErrorReporter().reportError(error, StackTrace.current);
      await _deleteUploadedFiles(uploadedUrls);
      emit(StorageFailure(exception: error));
    }
  }

  Future<void> _deleteUploadedFiles(List<String> uploadedUrls) async {
    if (uploadedUrls.isNotEmpty) {
      for (final url in uploadedUrls) {
        try {
          await _storageService.deleteFile(url);
        } catch (e) {
          debugPrint('❌ [StorageBloc] Error deleting file $url: $e');
          final error = GenericStorageBlocException(
              details: 'Error deleting file after failed complete upload: $url: $e', severity: ErrorSeverity.high);
          ErrorReporter().reportError(error, StackTrace.current);
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> _isFileValid(LivitLocationMediaFile file) async {
    List<Map<String, dynamic>> fileProperties = [];
    if (file.filePath == null) {
      throw GenericStorageBlocException(details: 'File has no path');
    }
    if (file is LivitLocationMediaVideo) {
      fileProperties.add((await _isFileValid(file.cover))[0]);
      if (!FirebaseStorageConstants.validVideoExtensions.contains(file.filePath!.split('.').last)) {
        throw InvalidFileExtensionException(details: 'Video has invalid extension');
      }
      if (await File(file.filePath!).length() > FirebaseStorageConstants.maxVideoSizeInMB * 1024 * 1024) {
        throw FileSizeTooLargeException(details: 'Video is too large');
      }
      fileProperties.add({'type': 'video/${file.filePath!.split('.').last}', 'size': (await File(file.filePath!).length())});
    } else {
      if (!FirebaseStorageConstants.validImageExtensions.contains(file.filePath!.split('.').last)) {
        throw InvalidFileExtensionException(details: 'Image has invalid extension');
      }
      if (await File(file.filePath!).length() > FirebaseStorageConstants.maxImageSizeInMB * 1024 * 1024) {
        throw FileSizeTooLargeException(details: 'Image is too large');
      }
      fileProperties.add({'type': 'image/${file.filePath!.split('.').last}', 'size': (await File(file.filePath!).length())});
    }
    return fileProperties;
  }

  Future<String> _uploadFile(LivitLocationMediaFile file, String signedUrl, Map<String, dynamic> fileProperties) async {
    debugPrint('📞 [StorageBloc] Calling uploadFileWithSignedUrl for $fileProperties');
    final String coverUrl = await _storageService.uploadFileWithSignedUrl(file.filePath!, signedUrl, fileProperties['type']);
    debugPrint('📥 [StorageBloc] Uploaded file $fileProperties');
    return coverUrl;
  }

  void _cleanData() {
    _signedUrls = [];
    _names = [];
    _fileProperties = [];
    _filePaths = [];
    _mediaToUpload = null;
  }
}
