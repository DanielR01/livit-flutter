import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/models/media/livit_media_file.dart';
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
import 'package:livit/utilities/debug/livit_debugger.dart';

class StorageBloc extends Bloc<StorageEvent, StorageState> {
  final StorageService _storageService;
  final ErrorReporter _errorReporter = ErrorReporter(viewName: 'StorageBloc');
  final LivitDebugger _debugger = const LivitDebugger('storage_bloc', isDebugEnabled: true);
  List<FileToUpload> _filesToUpload = [];
  String? _locationId;
  String? _eventId;

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

    // Add event handlers for event media
    on<VerifyEventMedia>(_onVerifyEventMedia);
    on<SetEventMedia>(_onSetEventMedia);
    on<DeleteEventMedia>(_onDeleteEventMedia);
  }

  Future<void> _onVerifyLocationMedia(
    VerifyLocationMedia event,
    Emitter<StorageState> emit,
  ) async {
    _debugger.debPrint('Verifying location media', DebugMessageType.verifying);
    _filesToUpload = [];
    _loadingStates = {};
    _exceptions = {};
    _locationId = event.location.id;
    _loadingStates[event.location.id] = LoadingState.verifying;
    for (final file in event.location.media!.files!) {
      if (file?.filePath == null) continue;
      _loadingStates[file!.filePath!] = LoadingState.verifying;
    }
    _debugger.debPrint('Loading states: $_loadingStates', DebugMessageType.info);
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
          _debugger.debPrint('Error verifying file: $e', DebugMessageType.error);
          _errorReporter.reportError(e, StackTrace.current);
          _exceptions[event.location.id] = {
            ..._exceptions[event.location.id] ?? {},
            file.filePath!: e is StorageBlocException ? e : GenericStorageBlocException(details: e.toString())
          };
          _loadingStates[event.location.media!.files!.indexOf(file).toString()] = LoadingState.error;
        }
      }
    }
    _debugger.debPrint('Validation completed', DebugMessageType.done);
    _debugger.debPrint('File properties: $_filesToUpload', DebugMessageType.info);
    final int failedFiles = _loadingStates.values.where((state) => state == LoadingState.error).length;
    if (failedFiles > 0) {
      _debugger.debPrint('$failedFiles files failed validation', DebugMessageType.error);
      _loadingStates[_locationId!] = LoadingState.error;
    } else {
      _debugger.debPrint('All files passed validation', DebugMessageType.done);
      _loadingStates[_locationId!] = LoadingState.verified;
    }
    _debugger.debPrint('Loading states: $_loadingStates', DebugMessageType.info);
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
      _debugger.debPrint('Calling deleteOldLocationMedia', DebugMessageType.methodCalling);
      await _storageService.deleteLocationMedia(event.locationId);
      _debugger.debPrint('Calling deleteOldLocationMedia done', DebugMessageType.done);
      _loadingStates[event.locationId] = LoadingState.deleted;
      _debugger.debPrint('Loading states: $_loadingStates', DebugMessageType.info);
      emit(StorageLoaded(loadingStates: _loadingStates, exceptions: _exceptions));
    } on UnavailableStorageException catch (e) {
      _debugger.debPrint('Error deleting location media: $e', DebugMessageType.error);
      _loadingStates[event.locationId] = LoadingState.error;
      _exceptions[event.locationId] = {'error': UnavailableStorageBlocException(details: e.toString())};
      _debugger.debPrint('Loading states: $_loadingStates', DebugMessageType.info);
      emit(StorageLoaded(loadingStates: _loadingStates, exceptions: _exceptions));
    } catch (e) {
      if (e is ObjectNotFoundStorageException) {
        _debugger.debPrint('Object not found, deleting location media done', DebugMessageType.done);
        _loadingStates[event.locationId] = LoadingState.deleted;
        _debugger.debPrint('Loading states: $_loadingStates', DebugMessageType.info);
        emit(StorageLoaded(loadingStates: _loadingStates, exceptions: _exceptions));
        return;
      }
      _debugger.debPrint('Error deleting location media: $e', DebugMessageType.error);
      _loadingStates[event.locationId] = LoadingState.error;
      _exceptions[event.locationId] = {'error': GenericStorageBlocException(details: e.toString())};
      _debugger.debPrint('Loading states: $_loadingStates', DebugMessageType.info);
      emit(StorageLoaded(loadingStates: _loadingStates, exceptions: _exceptions));
    }
  }

  Future<void> _onSetLocationMedia(
    SetLocationMedia event,
    Emitter<StorageState> emit,
  ) async {
    _exceptions = {};
    _debugger.debPrint('Setting location media', DebugMessageType.updating);
    if (_locationId == null) {
      throw LocationMediaNotVerifiedException(technicalDetails: 'Location ID is null');
    }
    _loadingStates[_locationId!] = LoadingState.uploading;
    _debugger.debPrint('Loading states: $_loadingStates', DebugMessageType.info);
    emit(StorageLoaded(loadingStates: _loadingStates, exceptions: _exceptions));

    final List<FileToUpload> uploadedFiles = [];
    try {
      _debugger.debPrint('Files to upload: ${_filesToUpload.length}', DebugMessageType.info);
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
          _debugger.debPrint(
              'Uploaded ${uploadedFiles.length + failedFiles.length}/${_filesToUpload.length + failedFiles.length + uploadedFiles.length}, file: $fileToUpload',
              DebugMessageType.done);
        } on UnavailableStorageException catch (e) {
          _exceptions[_locationId!] = {
            ..._exceptions[_locationId] ?? {},
            fileToUpload.filePath: UnavailableStorageBlocException(details: e.toString())
          };
          _loadingStates[fileToUpload.filePath] = LoadingState.error;
          failedFiles.add(fileToUpload);
          _filesToUpload.remove(fileToUpload);
          _debugger.debPrint('Loading states: $_loadingStates', DebugMessageType.info);
          emit(StorageLoaded(loadingStates: _loadingStates, exceptions: _exceptions));
          _debugger.debPrint(
              'Error uploading file ${uploadedFiles.length + failedFiles.length}/${_filesToUpload.length + failedFiles.length + uploadedFiles.length}, file: $fileToUpload, error: $e',
              DebugMessageType.error);
        } catch (e) {
          _errorReporter.reportError(e, StackTrace.current);
          _exceptions[_locationId!] = {
            ..._exceptions[_locationId] ?? {},
            fileToUpload.filePath: e is StorageBlocException ? e : GenericStorageBlocException(details: e.toString())
          };
          _loadingStates[fileToUpload.filePath] = LoadingState.error;
          failedFiles.add(fileToUpload);
          _filesToUpload.remove(fileToUpload);
          _debugger.debPrint('Loading states: $_loadingStates', DebugMessageType.info);
          emit(StorageLoaded(loadingStates: _loadingStates, exceptions: _exceptions));
          _debugger.debPrint(
              'Error uploading file ${uploadedFiles.length + failedFiles.length}/${_filesToUpload.length + failedFiles.length + uploadedFiles.length}, file: $fileToUpload, error: $e',
              DebugMessageType.error);
        }
      }
      _debugger.debPrint('Uploaded ${uploadedFiles.length} files', DebugMessageType.done);
      _loadingStates[_locationId!] = LoadingState.uploaded;
      _debugger.debPrint('Loading states: $_loadingStates', DebugMessageType.info);
      emit(StorageLoaded(loadingStates: _loadingStates, exceptions: _exceptions));
    } on UnavailableStorageException catch (e) {
      _debugger.debPrint('Error uploading files: $e', DebugMessageType.error);
      _exceptions[_locationId!] = {..._exceptions[_locationId] ?? {}, 'error': UnavailableStorageBlocException(details: e.toString())};
      _loadingStates[_locationId!] = LoadingState.error;
      for (final loadingState in _loadingStates.entries) {
        if (loadingState.value != LoadingState.error && loadingState.value != LoadingState.uploaded) {
          _loadingStates[loadingState.key] = LoadingState.aborted;
        }
      }
      _debugger.debPrint('Loading states: $_loadingStates', DebugMessageType.info);
      emit(StorageLoaded(loadingStates: _loadingStates, exceptions: _exceptions));
    } catch (e) {
      final error = e is StorageBlocFileSizeTooLargeException ? e : GenericStorageBlocException(details: e.toString());
      _debugger.debPrint('Error uploading files: $error', DebugMessageType.error);
      _errorReporter.reportError(error, StackTrace.current);
      _exceptions[_locationId!] = {..._exceptions[_locationId] ?? {}, 'error': error};
      _loadingStates[_locationId!] = LoadingState.error;
      for (final loadingState in _loadingStates.entries) {
        if (loadingState.value != LoadingState.error && loadingState.value != LoadingState.uploaded) {
          _loadingStates[loadingState.key] = LoadingState.aborted;
        }
      }
      _debugger.debPrint('Loading states: $_loadingStates', DebugMessageType.info);
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
    _debugger.debPrint('Calling uploadFile for $fileToUpload', DebugMessageType.methodCalling);
    final List<String> fileUrls = await _storageService.uploadLocationMediaFile(fileToUpload: fileToUpload);
    _debugger.debPrint('Uploaded file $fileToUpload', DebugMessageType.done);
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

  Future<void> _onVerifyEventMedia(
    VerifyEventMedia event,
    Emitter<StorageState> emit,
  ) async {
    _debugger.debPrint('Starting event media verification process', DebugMessageType.verifying);
    _debugger.debPrint('Event ID: ${event.event.id}', DebugMessageType.info);

    _filesToUpload = [];
    _loadingStates = {};
    _exceptions = {};
    _eventId = event.event.id;

    if (_eventId == null) {
      _debugger.debPrint('Event ID is null, cannot proceed with verification', DebugMessageType.error);
      throw EventMediaNotVerifiedException(technicalDetails: 'Event ID is null');
    }

    _loadingStates[_eventId!] = LoadingState.verifying;

    // Check if event has media
    _debugger.debPrint('Event media count: ${event.event.media.media.length}', DebugMessageType.info);
    if (event.event.media.media.isEmpty) {
      _debugger.debPrint('No media found in event, marking as verified', DebugMessageType.info);
      _loadingStates[_eventId!] = LoadingState.verified;
      emit(StorageLoaded(loadingStates: _loadingStates, exceptions: _exceptions));
      return;
    }

    // Track each media file's loading state
    _debugger.debPrint('Tracking loading states for ${event.event.media.media.length} media files', DebugMessageType.info);
    for (int i = 0; i < event.event.media.media.length; i++) {
      final file = event.event.media.media[i];
      if (file.filePath == null) {
        _debugger.debPrint('File at index $i has null path', DebugMessageType.error);
        _loadingStates[file.filePath!] = LoadingState.error;
        _loadingStates[_eventId!] = LoadingState.error;
        _exceptions[_eventId!] = {
          ..._exceptions[_eventId!] ?? {},
          file.filePath!: GenericStorageBlocException(details: 'File path is null')
        };
        break;
      }
      _loadingStates[file.filePath!] = LoadingState.verifying;
      _debugger.debPrint('Set loading state for file ${file.filePath}', DebugMessageType.info);
    }

    _debugger.debPrint('Loading states initialized: ${_loadingStates.length} entries', DebugMessageType.info);
    emit(StorageLoaded(loadingStates: _loadingStates, exceptions: _exceptions));

    if (_loadingStates[_eventId!] == LoadingState.error) {
      _debugger.debPrint('Event media verification failed at initial check', DebugMessageType.error);
      return;
    }

    // Verify each media file
    _debugger.debPrint('Starting validation of individual media files', DebugMessageType.verifying);
    for (int i = 0; i < event.event.media.media.length; i++) {
      final file = event.event.media.media[i];
      _debugger.debPrint('Validating file ${i + 1}/${event.event.media.media.length}: ${file.filePath}', DebugMessageType.verifying);

      try {
        if (file is LivitMediaVideo) {
          _debugger.debPrint('Processing video file with cover', DebugMessageType.info);
          final List<Map<String, dynamic>> fileProperties = await _isFileValid(file);
          _debugger.debPrint('Video file validated successfully', DebugMessageType.done);
          _debugger.debPrint('Video size: ${fileProperties[1]['size']} bytes, type: ${fileProperties[1]['type']}', DebugMessageType.info);
          _debugger.debPrint('Cover size: ${fileProperties[0]['size']} bytes, type: ${fileProperties[0]['type']}', DebugMessageType.info);

          _filesToUpload.add(VideoFileToUpload(
            reference: EventMediaStorageReference(
              eventId: _eventId!,
              index: i.toString(),
            ),
            coverPath: file.cover.filePath!,
            coverContentType: fileProperties[0]['type'],
            coverSize: fileProperties[0]['size'],
            filePath: file.filePath!,
            contentType: fileProperties[1]['type'],
            size: fileProperties[1]['size'],
          ));
          _debugger.debPrint('Added video file to upload queue at index $i', DebugMessageType.done);
        } else {
          _debugger.debPrint('Processing image file', DebugMessageType.info);
          final List<Map<String, dynamic>> fileProperties = await _isFileValid(file);
          _debugger.debPrint('Image file validated successfully', DebugMessageType.done);
          _debugger.debPrint('Image size: ${fileProperties[0]['size']} bytes, type: ${fileProperties[0]['type']}', DebugMessageType.info);

          _filesToUpload.add(ImageFileToUpload(
            filePath: file.filePath!,
            contentType: fileProperties[0]['type'],
            reference: EventMediaStorageReference(
              eventId: _eventId!,
              index: i.toString(),
            ),
            size: fileProperties[0]['size'],
          ));
          _debugger.debPrint('Added image file to upload queue at index $i', DebugMessageType.done);
        }
        _loadingStates[file.filePath!] = LoadingState.verified;
      } catch (e) {
        _debugger.debPrint('Error validating file at index $i: $e', DebugMessageType.error);
        _errorReporter.reportError(e, StackTrace.current);
        _exceptions[_eventId!] = {
          ..._exceptions[_eventId!] ?? {},
          file.filePath!: e is StorageBlocException ? e : GenericStorageBlocException(details: e.toString())
        };
        _loadingStates[file.filePath!] = LoadingState.error;
        _debugger.debPrint('File marked as error: ${file.filePath}', DebugMessageType.error);
      }
    }

    _debugger.debPrint('Event media validation completed', DebugMessageType.done);
    _debugger.debPrint('Files to upload: ${_filesToUpload.length}', DebugMessageType.info);

    final int failedFiles = _loadingStates.values.where((state) => state == LoadingState.error).length;
    if (failedFiles > 0) {
      _debugger.debPrint('$failedFiles event media files failed validation', DebugMessageType.error);
      _loadingStates[_eventId!] = LoadingState.error;
      _filesToUpload = [];
      _debugger.debPrint('Upload queue cleared due to validation errors', DebugMessageType.info);
    } else {
      _debugger.debPrint('All ${_filesToUpload.length} event media files passed validation', DebugMessageType.done);
      _loadingStates[_eventId!] = LoadingState.verified;
    }

    _debugger.debPrint('Final loading states: $_loadingStates', DebugMessageType.info);
    _debugger.debPrint('Final exceptions count: ${(_exceptions[_eventId]?.length ?? 0)}', DebugMessageType.info);
    emit(StorageLoaded(loadingStates: _loadingStates, exceptions: _exceptions));
  }

  Future<void> _onSetEventMedia(
    SetEventMedia event,
    Emitter<StorageState> emit,
  ) async {
    _debugger.debPrint('Starting event media upload process', DebugMessageType.uploading);
    _exceptions = {};

    if (_eventId == null) {
      _debugger.debPrint('Event ID is null, cannot proceed with upload', DebugMessageType.error);
      throw EventMediaNotVerifiedException(technicalDetails: 'Event ID is null');
    }

    _debugger.debPrint('Event ID: $_eventId', DebugMessageType.info);

    if (_filesToUpload.any((file) => file.reference is! EventMediaStorageReference)) {
      _debugger.debPrint('Invalid reference type found in files to upload', DebugMessageType.error);
      throw GenericStorageBlocException(details: 'File reference is not an EventMediaStorageReference');
    } else if (_filesToUpload.any((file) => (file.reference as EventMediaStorageReference).eventId != _eventId)) {
      _debugger.debPrint('Mismatched event ID found in file references', DebugMessageType.error);
      throw GenericStorageBlocException(details: 'File reference event ID does not match event ID');
    }

    _loadingStates[_eventId!] = LoadingState.uploading;
    _debugger.debPrint('Event status set to uploading', DebugMessageType.info);
    emit(StorageLoaded(loadingStates: _loadingStates, exceptions: _exceptions));

    final List<FileToUpload> uploadedFiles = [];
    try {
      _debugger.debPrint('Files queued for upload: ${_filesToUpload.length}', DebugMessageType.info);

      if (_filesToUpload.isEmpty) {
        _debugger.debPrint('No files to upload, marking as complete', DebugMessageType.done);
        _loadingStates[_eventId!] = LoadingState.uploaded;
        emit(StorageLoaded(loadingStates: _loadingStates, exceptions: _exceptions));
        return;
      }

      final List<FileToUpload> failedFiles = [];

      while (_filesToUpload.isNotEmpty) {
        final FileToUpload fileToUpload = _filesToUpload.first;
        final fileIndex = (fileToUpload.reference as EventMediaStorageReference).index;
        _debugger.debPrint('Processing upload for file at index $fileIndex: ${fileToUpload.filePath}', DebugMessageType.uploading);

        try {
          _debugger.debPrint('Starting file upload to Firebase Storage', DebugMessageType.uploading);
          await _uploadEventFile(fileToUpload);
          uploadedFiles.add(fileToUpload);
          _loadingStates[fileToUpload.filePath] = LoadingState.uploaded;
          _filesToUpload.remove(fileToUpload);

          _debugger.debPrint(
              'Upload progress: ${uploadedFiles.length + failedFiles.length}/${_filesToUpload.length + failedFiles.length + uploadedFiles.length} files',
              DebugMessageType.info);
        } catch (e) {
          _debugger.debPrint('Error uploading file at index $fileIndex: $e', DebugMessageType.error);
          _errorReporter.reportError(e, StackTrace.current);
          _exceptions[_eventId!] = {
            ..._exceptions[_eventId!] ?? {},
            fileToUpload.filePath: e is StorageBlocException ? e : GenericStorageBlocException(details: e.toString())
          };
          _loadingStates[fileToUpload.filePath] = LoadingState.error;
          failedFiles.add(fileToUpload);
          _filesToUpload.remove(fileToUpload);
          _debugger.debPrint('File added to failed uploads list', DebugMessageType.error);

          emit(StorageLoaded(loadingStates: _loadingStates, exceptions: _exceptions));
        }
      }

      _debugger.debPrint('Completed ${uploadedFiles.length} uploads with ${failedFiles.length} failures', DebugMessageType.done);

      if (failedFiles.isEmpty) {
        _loadingStates[_eventId!] = LoadingState.uploaded;
        _debugger.debPrint('All files uploaded successfully', DebugMessageType.done);
      } else {
        _loadingStates[_eventId!] = LoadingState.error;
        _debugger.debPrint('Upload process completed with errors', DebugMessageType.error);
      }

      emit(StorageLoaded(loadingStates: _loadingStates, exceptions: _exceptions));
    } catch (e) {
      _debugger.debPrint('Error in upload process: $e', DebugMessageType.error);
      _debugger.debPrint('Stack trace: ${StackTrace.current}', DebugMessageType.error);
      _errorReporter.reportError(e, StackTrace.current);
      _exceptions[_eventId!] = {..._exceptions[_eventId!] ?? {}, 'error': GenericStorageBlocException(details: e.toString())};
      _loadingStates[_eventId!] = LoadingState.error;

      for (final loadingState in _loadingStates.entries) {
        if (loadingState.value != LoadingState.error && loadingState.value != LoadingState.uploaded) {
          _loadingStates[loadingState.key] = LoadingState.aborted;
          _debugger.debPrint('Setting state to aborted for: ${loadingState.key}', DebugMessageType.info);
        }
      }

      emit(StorageLoaded(loadingStates: _loadingStates, exceptions: _exceptions));
    }
  }

  Future<void> _onDeleteEventMedia(
    DeleteEventMedia event,
    Emitter<StorageState> emit,
  ) async {
    _debugger.debPrint('Starting deletion of event media for ID: ${event.eventId}', DebugMessageType.deleting);
    _loadingStates[event.eventId] = LoadingState.deleting;
    _exceptions = {};
    emit(StorageLoaded(loadingStates: _loadingStates, exceptions: _exceptions));

    try {
      _debugger.debPrint('Calling storage service to delete event media files', DebugMessageType.deleting);
      await _storageService.deleteEventMedia(event.eventId);
      _debugger.debPrint('Event media deletion completed successfully', DebugMessageType.done);
      _loadingStates[event.eventId] = LoadingState.deleted;
      emit(StorageLoaded(loadingStates: _loadingStates, exceptions: _exceptions));
    } catch (e) {
      _debugger.debPrint('Error deleting event media: $e', DebugMessageType.error);
      _debugger.debPrint('Stack trace: ${StackTrace.current}', DebugMessageType.error);
      _loadingStates[event.eventId] = LoadingState.error;
      _exceptions[event.eventId] = {'error': GenericStorageBlocException(details: e.toString())};
      _debugger.debPrint('Marking event as error state', DebugMessageType.error);
      emit(StorageLoaded(loadingStates: _loadingStates, exceptions: _exceptions));
    }
  }

  Future<List<String>> _uploadEventFile(FileToUpload fileToUpload) async {
    _debugger.debPrint('Preparing to upload file: ${fileToUpload.filePath}', DebugMessageType.uploading);

    final fileRef = fileToUpload.reference as EventMediaStorageReference;
    _debugger.debPrint('Upload target - Event ID: ${fileRef.eventId}, Index: ${fileRef.index}', DebugMessageType.info);

    if (fileToUpload is VideoFileToUpload) {
      _debugger.debPrint('Upload type: Video with cover', DebugMessageType.info);
      _debugger.debPrint('Video size: ${fileToUpload.size} bytes, Cover size: ${fileToUpload.coverSize} bytes', DebugMessageType.info);
    } else {
      _debugger.debPrint('Upload type: Image', DebugMessageType.info);
      _debugger.debPrint('Image size: ${fileToUpload.size} bytes', DebugMessageType.info);
    }

    _debugger.debPrint('Calling storage service to perform upload', DebugMessageType.uploading);
    final List<String> fileUrls = await _storageService.uploadEventMediaFile(fileToUpload: fileToUpload);
    _debugger.debPrint('Upload completed, received ${fileUrls.length} URLs', DebugMessageType.done);

    for (int i = 0; i < fileUrls.length; i++) {
      _debugger.debPrint('URL $i: ${fileUrls[i]}', DebugMessageType.info);
    }

    return fileUrls;
  }
}
