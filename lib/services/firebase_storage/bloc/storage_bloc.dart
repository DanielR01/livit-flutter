import 'dart:io';

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
import 'package:livit/services/firebase_storage/storage_service.dart';
import 'package:livit/services/firestore_storage/cloud_functions/cloud_functions_exceptions.dart';
import 'package:livit/services/firestore_storage/cloud_functions/firestore_cloud_functions.dart';
import 'package:livit/utilities/media/media_file_cleanup.dart';

class StorageBloc extends Bloc<StorageEvent, StorageState> {
  final StorageService _storageService;
  final FirestoreCloudFunctions _cloudFunctions;

  StorageBloc({
    required StorageService storageService,
    required FirestoreCloudFunctions cloudFunctions,
  })  : _storageService = storageService,
        _cloudFunctions = cloudFunctions,
        super(const StorageInitial()) {
    on<SetLocationMedia>(_onSetLocationMedia);
  }
  Future<void> _onSetLocationMedia(
    SetLocationMedia event,
    Emitter<StorageState> emit,
  ) async {
    emit(const StorageUploading());
    final List<String> uploadedUrls = [];
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
      final List<String> signedUrls = await _cloudFunctions.getLocationMediaUploadUrls(
        locationId: event.locationId,
        fileSizes: fileProperties.map((e) => e['size'] as int).toList(),
        fileTypes: fileProperties.map((e) => e['type'] as String).toList(),
        names: names,
      );
      debugPrint('📥 [StorageBloc] Obtained ${signedUrls.length} signed URLs');
      if (signedUrls.length != fileProperties.length) {
        throw GenericStorageBlocException(details: 'Signed URLs length does not match file sizes length');
      }
      emit(StorageSignedUrlsObtained(media: event.media));
      int filesUploaded = 0;
      int signedUrlsUsed = 0;
      LivitLocationMedia newMedia = LivitLocationMedia(mainFile: event.media.mainFile, secondaryFiles: event.media.secondaryFiles);
      while (signedUrlsUsed < signedUrls.length) {
        final LivitLocationMediaFile fileToUpload =
            filesUploaded == 0 ? event.media.mainFile! : event.media.secondaryFiles![filesUploaded - 1]!;
        if (fileToUpload is LivitLocationMediaVideo) {
          final String coverUrl = await _uploadFile(fileToUpload.cover, signedUrls[signedUrlsUsed], fileProperties[signedUrlsUsed]);
          signedUrlsUsed++;
          final String videoUrl = await _uploadFile(fileToUpload, signedUrls[signedUrlsUsed], fileProperties[signedUrlsUsed]);
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
          final String imageUrl = await _uploadFile(fileToUpload, signedUrls[signedUrlsUsed], fileProperties[signedUrlsUsed]);
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
}
