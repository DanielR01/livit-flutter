import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/models/media/location_media_file.dart';
import 'package:livit/services/error_reporting/error_reporter.dart';
import 'package:livit/services/exceptions/base_exception.dart';
import 'package:livit/services/firebase_storage/bloc/storage_bloc_exception.dart';
import 'package:livit/services/firebase_storage/bloc/storage_event.dart';
import 'package:livit/services/firebase_storage/bloc/storage_state.dart';
import 'package:livit/services/firebase_storage/firebase_storage_constants.dart';
import 'package:livit/services/firebase_storage/storage_service/file_to_upload.dart';
import 'package:livit/services/firebase_storage/storage_service/storage_reference.dart';
import 'package:livit/services/firebase_storage/storage_service/storage_service.dart';
import 'package:livit/services/firebase_storage/storage_service/storage_service_exceptions.dart';
import 'package:livit/services/cloud_functions/firestore_cloud_functions.dart';

class StorageBloc extends Bloc<StorageEvent, StorageState> {
  final StorageService _storageService;

  List<FileToUpload> _filesToUpload = [];
  String? _locationId;

  Map<String, LoadingState> _loadingStates = {};
  Map<String, Map<String, LivitException>> _exceptions = {};

  StorageBloc({
    required StorageService storageService,
    required FirestoreCloudFunctions cloudFunctions,
  })  : _storageService = storageService,
        super(const StorageInitial()) {
    on<SetLocationMedia>(_onSetLocationMedia);
    on<DeleteLocationMedia>(_onDeleteLocationMedia);
    on<VerifyLocationMedia>(_onVerifyLocationMedia);
  }

  Future<void> _onVerifyLocationMedia(
    VerifyLocationMedia event,
    Emitter<StorageState> emit,
  ) async {
    debugPrint('🔍 [StorageBloc] Verifying location media');
    _filesToUpload = [];
    _loadingStates = {};
    _exceptions = {};
    _locationId = event.location.id;
    _loadingStates[event.location.id] = LoadingState.verifying;
    for (final file in event.location.media!.files!) {
      if (file?.filePath == null) continue;
      _loadingStates[file!.filePath!] = LoadingState.verifying;
    }
    debugPrint('🔍 [StorageBloc] Loading states: $_loadingStates');
    emit(StorageLoaded(loadingStates: _loadingStates, exceptions: _exceptions));
    if (event.location.media?.files != null && event.location.media!.files!.isNotEmpty) {
      for (final file in event.location.media!.files!) {
        if (file == null) continue;
        try {
          if (file is LivitMediaVideo) {
            final List<Map<String, dynamic>> fileProperties = await _isFileValid(file);
            _filesToUpload.add(VideoFileToUpload(
                reference: LocationMediaStorageReference(locationId: event.location.id),
                coverPath: file.cover.filePath!,
                coverContentType: fileProperties[0]['type'],
                coverSize: fileProperties[0]['size'],
                filePath: file.filePath!,
                contentType: fileProperties[1]['type'],
                size: fileProperties[1]['size']));
          } else {
            final List<Map<String, dynamic>> fileProperties = await _isFileValid(file);
            _filesToUpload.add(ImageFileToUpload(
                filePath: file.filePath!,
                contentType: fileProperties[0]['type'],
                reference: LocationMediaStorageReference(locationId: event.location.id),
                size: fileProperties[0]['size']));
          }
          _loadingStates[file.filePath!] = LoadingState.verified;
        } catch (e) {
          debugPrint('❌ [StorageBloc] Error verifying file: $e');
          ErrorReporter().reportError(e, StackTrace.current);
          _exceptions[event.location.id] = {
            ..._exceptions[event.location.id] ?? {},
            file.filePath!: e is StorageBlocException ? e : GenericStorageBlocException(details: e.toString())
          };
          _loadingStates[event.location.media!.files!.indexOf(file).toString()] = LoadingState.error;
        }
      }
    }
    debugPrint('✅ [StorageBloc] Validation completed');
    debugPrint('- File properties: $_filesToUpload');
    final int failedFiles = _loadingStates.values.where((state) => state == LoadingState.error).length;
    if (failedFiles > 0) {
      debugPrint('❌ [StorageBloc] $failedFiles files failed validation');
      _loadingStates[_locationId!] = LoadingState.error;
    } else {
      debugPrint('✅ [StorageBloc] All files passed validation');
      _loadingStates[_locationId!] = LoadingState.verified;
    }
    debugPrint('🔍 [StorageBloc] Loading states: $_loadingStates');
    emit(StorageLoaded(loadingStates: _loadingStates, exceptions: _exceptions));
  }

  Future<void> _onDeleteLocationMedia(
    DeleteLocationMedia event,
    Emitter<StorageState> emit,
  ) async {
    _loadingStates[event.locationId] = LoadingState.deleting;
    _exceptions = {};
    emit(StorageLoaded(loadingStates: _loadingStates, exceptions: _exceptions));
    try {
      debugPrint('📞 [StorageBloc] Calling deleteOldLocationMedia');
      await _storageService.deleteLocationMedia(event.locationId);
      debugPrint('✅ [StorageBloc] Calling deleteOldLocationMedia done');
      _loadingStates[event.locationId] = LoadingState.deleted;
      debugPrint('🔍 [StorageBloc] Loading states: $_loadingStates');
      emit(StorageLoaded(loadingStates: _loadingStates, exceptions: _exceptions));
    } on UnavailableStorageException catch (e) {
      debugPrint('❌ [StorageBloc] Error deleting location media: $e');
      _loadingStates[event.locationId] = LoadingState.error;
      _exceptions[event.locationId] = {'error': UnavailableStorageBlocException(details: e.toString())};
      debugPrint('🔍 [StorageBloc] Loading states: $_loadingStates');
      emit(StorageLoaded(loadingStates: _loadingStates, exceptions: _exceptions));
    } catch (e) {
      if (e is ObjectNotFoundStorageException) {
        debugPrint('✅ [StorageBloc] Object not found, deleting location media done');
        _loadingStates[event.locationId] = LoadingState.deleted;
        debugPrint('🔍 [StorageBloc] Loading states: $_loadingStates');
        emit(StorageLoaded(loadingStates: _loadingStates, exceptions: _exceptions));
        return;
      }
      debugPrint('❌ [StorageBloc] Error deleting location media: $e');
      _loadingStates[event.locationId] = LoadingState.error;
      _exceptions[event.locationId] = {'error': GenericStorageBlocException(details: e.toString())};
      debugPrint('🔍 [StorageBloc] Loading states: $_loadingStates');
      emit(StorageLoaded(loadingStates: _loadingStates, exceptions: _exceptions));
    }
  }

  Future<void> _onSetLocationMedia(
    SetLocationMedia event,
    Emitter<StorageState> emit,
  ) async {
    _exceptions = {};
    debugPrint('🏁 [StorageBloc] Setting location media');
    if (_locationId == null) {
      throw LocationMediaNotVerifiedException(details: 'Location ID is null');
    }
    _loadingStates[_locationId!] = LoadingState.uploading;
    debugPrint('🔍 [StorageBloc] Loading states: $_loadingStates');
    emit(StorageLoaded(loadingStates: _loadingStates, exceptions: _exceptions));

    final List<FileToUpload> uploadedFiles = [];
    try {
      debugPrint('ℹ️ [StorageBloc] Files to upload: ${_filesToUpload.length}');
      if (_filesToUpload.isEmpty) {
        throw IncompleteDataException(details: _filesToUpload.toString());
      }
      final List<FileToUpload> failedFiles = [];
      while (_filesToUpload.isNotEmpty) {
        final FileToUpload fileToUpload = _filesToUpload.first;
        try {
          await _uploadFile(fileToUpload);
          uploadedFiles.add(fileToUpload);
          _loadingStates[fileToUpload.filePath] = LoadingState.uploaded;
          _filesToUpload.remove(fileToUpload);
          debugPrint(
              '✅ [StorageBloc] Uploaded ${uploadedFiles.length + failedFiles.length}/${_filesToUpload.length + failedFiles.length + uploadedFiles.length}, file: $fileToUpload');
        } on UnavailableStorageException catch (e) {
          _exceptions[_locationId!] = {..._exceptions[_locationId] ?? {}, fileToUpload.filePath: UnavailableStorageBlocException(details: e.toString())};
          _loadingStates[fileToUpload.filePath] = LoadingState.error;
          failedFiles.add(fileToUpload);
          _filesToUpload.remove(fileToUpload);
          debugPrint('🔍 [StorageBloc] Loading states: $_loadingStates');
          emit(StorageLoaded(loadingStates: _loadingStates, exceptions: _exceptions));
          debugPrint(
              '❌ [StorageBloc] Error uploading file ${uploadedFiles.length + failedFiles.length}/${_filesToUpload.length + failedFiles.length + uploadedFiles.length}, file: $fileToUpload, error: $e');
        } catch (e) {
          ErrorReporter().reportError(e, StackTrace.current);
          _exceptions[_locationId!] = {..._exceptions[_locationId] ?? {}, fileToUpload.filePath: e is StorageBlocException ? e : GenericStorageBlocException(details: e.toString())};
          _loadingStates[fileToUpload.filePath] = LoadingState.error;
          failedFiles.add(fileToUpload);
          _filesToUpload.remove(fileToUpload);
          debugPrint('🔍 [StorageBloc] Loading states: $_loadingStates');
          emit(StorageLoaded(loadingStates: _loadingStates, exceptions: _exceptions));
          debugPrint(
              '❌ [StorageBloc] Error uploading file ${uploadedFiles.length + failedFiles.length}/${_filesToUpload.length + failedFiles.length + uploadedFiles.length}, file: $fileToUpload, error: $e');
        }
      }
      debugPrint('📥 [StorageBloc] Uploaded ${uploadedFiles.length} files');
      _loadingStates[_locationId!] = LoadingState.uploaded;
      debugPrint('🔍 [StorageBloc] Loading states: $_loadingStates');
      emit(StorageLoaded(loadingStates: _loadingStates, exceptions: _exceptions));
    } on UnavailableStorageException catch (e) {
      debugPrint('❌ [StorageBloc] Error uploading files: $e');
      _exceptions[_locationId!] = {..._exceptions[_locationId] ?? {}, 'error': UnavailableStorageBlocException(details: e.toString())};
      _loadingStates[_locationId!] = LoadingState.error;
      for (final loadingState in _loadingStates.entries) {
        if (loadingState.value != LoadingState.error && loadingState.value != LoadingState.uploaded) {
          _loadingStates[loadingState.key] = LoadingState.aborted;
        }
      }
      debugPrint('🔍 [StorageBloc] Loading states: $_loadingStates');
      emit(StorageLoaded(loadingStates: _loadingStates, exceptions: _exceptions));
    } catch (e) {
      final error = e is StorageBlocFileSizeTooLargeException ? e : GenericStorageBlocException(details: e.toString());
      debugPrint('❌ [StorageBloc] Error uploading files: $error');
      ErrorReporter().reportError(error, StackTrace.current);
      _exceptions[_locationId!] = {..._exceptions[_locationId] ?? {}, 'error': error};
      _loadingStates[_locationId!] = LoadingState.error;
      for (final loadingState in _loadingStates.entries) {
        if (loadingState.value != LoadingState.error && loadingState.value != LoadingState.uploaded) {
          _loadingStates[loadingState.key] = LoadingState.aborted;
        }
      }
      debugPrint('🔍 [StorageBloc] Loading states: $_loadingStates');
      emit(StorageLoaded(loadingStates: _loadingStates, exceptions: _exceptions));
    }
  }

  Future<List<Map<String, dynamic>>> _isFileValid(LivitMediaFile file) async {
    List<Map<String, dynamic>> fileProperties = [];
    if (file.filePath == null || !File(file.filePath!).existsSync()) {
      throw FileDoesNotExistException(details: file.filePath);
    }
    if (file is LivitMediaVideo) {
      fileProperties.add((await _isFileValid(file.cover))[0]);
      if (!FirebaseStorageConstants.validVideoExtensions.contains(file.filePath!.split('.').last)) {
        throw InvalidFileExtensionException(details: 'Video has invalid extension');
      }
      if (await File(file.filePath!).length() > FirebaseStorageConstants.maxVideoSizeInMB * 1024 * 1024) {
        throw StorageBlocFileSizeTooLargeException(details: 'Video is too large');
      }
      fileProperties.add({'type': 'video/${file.filePath!.split('.').last}', 'size': (await File(file.filePath!).length())});
    } else {
      if (!FirebaseStorageConstants.validImageExtensions.contains(file.filePath!.split('.').last)) {
        throw InvalidFileExtensionException(details: 'Image has invalid extension');
      }
      if (await File(file.filePath!).length() > FirebaseStorageConstants.maxImageSizeInMB * 1024 * 1024) {
        throw StorageBlocFileSizeTooLargeException(details: 'Image is too large');
      }
      fileProperties.add({'type': 'image/${file.filePath!.split('.').last}', 'size': (await File(file.filePath!).length())});
    }
    return fileProperties;
  }

  Future<List<String>> _uploadFile(FileToUpload fileToUpload) async {
    debugPrint('📞 [StorageBloc] Calling uploadFile for $fileToUpload');
    final List<String> fileUrls = await _storageService.uploadLocationMediaFile(fileToUpload: fileToUpload);
    debugPrint('📥 [StorageBloc] Uploaded file $fileToUpload');
    return fileUrls;
  }

  Future<void> _onGetMediaFile(
    GetMediaFile event,
    Emitter<StorageState> emit,
  ) async {
    // emit(StorageDownloading());
    // final String url = await _storageService.getMediaFile(event.url);
    // emit(StorageMediaFileObtained(url: url));
  }
}
