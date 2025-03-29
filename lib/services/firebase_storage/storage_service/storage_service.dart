import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livit/models/location/location_media.dart';
import 'package:livit/models/media/livit_media_file.dart';
import 'package:livit/services/firebase_storage/storage_service/file_to_upload.dart';
import 'package:livit/services/firebase_storage/storage_service/storage_reference.dart';
import 'package:livit/services/firebase_storage/storage_service/storage_service_exceptions.dart';
import 'package:livit/models/location/location.dart';
import 'package:livit/utilities/debug/livit_debugger.dart';

class StorageService {
  static final StorageService _shared = StorageService._sharedInstance();
  StorageService._sharedInstance();
  factory StorageService() => _shared;

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _debugger = const LivitDebugger('StorageService', isDebugEnabled: true);

  Future<List<String>> uploadLocationMediaFile({required FileToUpload fileToUpload}) async {
    try {
      _debugger.debPrint('Uploading file: $fileToUpload', DebugMessageType.uploading);
      late final List<File> files;

      late final List<String> filenames;
      if (fileToUpload is ImageFileToUpload) {
        files = [File(fileToUpload.filePath)];
        filenames = [fileToUpload.filePath];
      } else if (fileToUpload is VideoFileToUpload) {
        final file = File(fileToUpload.filePath);
        final cover = File(fileToUpload.coverPath);
        files = [file, cover];
        filenames = [fileToUpload.filePath, fileToUpload.coverPath];
      } else {
        throw Exception('Invalid file type');
      }

      final List<Reference> refs = [];
      if (fileToUpload.reference is LocationMediaStorageReference) {
        for (final filename in filenames) {
          refs.add(_storage
              .ref()
              .child('locations')
              .child((fileToUpload.reference as LocationMediaStorageReference).locationId)
              .child(filename));
        }
      } else {
        throw Exception('Invalid reference type');
      }
      final List<TaskSnapshot> uploadTasks = [];
      if (fileToUpload is ImageFileToUpload) {
        final uploadTask = await refs[0].putFile(
          files[0],
          SettableMetadata(contentType: fileToUpload.contentType),
        );
        uploadTasks.add(uploadTask);
      } else if (fileToUpload is VideoFileToUpload) {
        final uploadTask = await refs[0].putFile(
          files[0],
          SettableMetadata(contentType: fileToUpload.contentType),
        );
        uploadTasks.add(uploadTask);
        final coverUploadTask = await refs[1].putFile(
          files[1],
          SettableMetadata(contentType: fileToUpload.coverContentType),
        );
        uploadTasks.add(coverUploadTask);
      } else {
        throw Exception('Invalid file type');
      }

      final List<String> downloadUrls = await Future.wait(uploadTasks.map((task) => task.ref.getDownloadURL()));

      final locationRef =
          FirebaseFirestore.instance.collection('locations').doc((fileToUpload.reference as LocationMediaStorageReference).locationId);
      final locationDoc = await locationRef.get();

      if (!locationDoc.exists) {
        throw ObjectNotFoundStorageException('Location not found');
      }

      final LivitLocation location = LivitLocation.fromDocument(locationDoc);
      final LivitLocationMedia? currentMedia = location.media;
      final List<LivitMediaFile?> updatedFiles = [...?currentMedia?.files];

      if (fileToUpload is ImageFileToUpload) {
        updatedFiles.add(LivitMediaImage(
          url: downloadUrls[0],
          filePath: filenames[0],
        ));
      } else if (fileToUpload is VideoFileToUpload) {
        updatedFiles.add(LivitMediaVideo(
          url: downloadUrls[0],
          filePath: filenames[0],
          cover: LivitMediaImage(url: downloadUrls[1], filePath: filenames[1]),
        ));
      }

      final LivitLocationMedia updatedMedia = currentMedia?.copyWith(files: updatedFiles) ?? LivitLocationMedia(files: updatedFiles);

      await locationRef.update({'media': updatedMedia.toMap()});

      _debugger.debPrint('File uploaded and Firestore updated', DebugMessageType.done);
      return downloadUrls;
    } on FirebaseException catch (e) {
      if (e.code == 'network-request-failed') {
        throw UnavailableStorageException('Storage service is unavailable');
      }
      rethrow;
    } catch (e) {
      _debugger.debPrint('Error uploading file: $e', DebugMessageType.error);
      rethrow;
    }
  }

  Future<void> deleteFile(String url) async {
    await _storage.refFromURL(url).delete();
  }

  Future<void> deleteLocationMedia(String locationId) async {
    try {
      _debugger.debPrint('Deleting location media for ID: $locationId', DebugMessageType.deleting);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final locationRef = FirebaseFirestore.instance.collection('locations').doc(locationId);
        final locationDoc = await transaction.get(locationRef);

        if (!locationDoc.exists) {
          throw ObjectNotFoundStorageException('Location not found');
        }

        // Create the correct storage reference
        final storageRef = _storage.ref().child('locations').child(locationId);
        _debugger.debPrint('Storage reference path: ${storageRef.fullPath}', DebugMessageType.fileTracking);

        try {
          final ListResult result = await storageRef.listAll();

          _debugger.debPrint('Found items:', DebugMessageType.fileTracking);
          _debugger.debPrint('- Files: ${result.items.length}', DebugMessageType.fileTracking);
          _debugger.debPrint('- Prefixes: ${result.prefixes.length}', DebugMessageType.fileTracking);

          // Delete all files in the main directory
          for (var item in result.items) {
            _debugger.debPrint('Deleting file: ${item.fullPath}', DebugMessageType.fileDeleting);
            await item.delete();
          }

          for (var prefix in result.prefixes) {
            final nestedResult = await prefix.listAll();
            _debugger.debPrint('Found nested items in ${prefix.fullPath}:', DebugMessageType.fileTracking);
            _debugger.debPrint('- Nested files: ${nestedResult.items.length}', DebugMessageType.fileTracking);

            for (var nestedItem in nestedResult.items) {
              _debugger.debPrint('Deleting nested file: ${nestedItem.fullPath}', DebugMessageType.fileDeleting);
              await nestedItem.delete();
            }
          }

          // Update Firestore document
          transaction.update(locationRef, {
            'media': LivitLocationMedia(files: []).toMap(),
          });

          _debugger.debPrint('Location media deleted successfully', DebugMessageType.done);
        } on FirebaseException catch (e) {
          if (e.code == 'unavailable') {
            throw UnavailableStorageException('Storage service is unavailable');
          }
          if (e.code != 'object-not-found') {
            _debugger.debPrint('Firebase error: ${e.code} - ${e.message}', DebugMessageType.error);
            rethrow;
          }
          _debugger.debPrint('No files found to delete', DebugMessageType.warning);
        }
      });

      _debugger.debPrint('Location media deleted and document updated successfully', DebugMessageType.done);
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') {
        throw UnavailableStorageException('Storage service is unavailable');
      }
      rethrow;
    } catch (e) {
      _debugger.debPrint('Error deleting location media: $e', DebugMessageType.error);
      rethrow;
    }
  }

  Future<List<String>> uploadEventMediaFile({required FileToUpload fileToUpload}) async {
    try {
      _debugger.debPrint('Starting event media file upload process', DebugMessageType.uploading);
      _debugger.debPrint('File path: ${fileToUpload.filePath}', DebugMessageType.info);
      _debugger.debPrint('Content type: ${fileToUpload.contentType}', DebugMessageType.info);
      _debugger.debPrint('File size: ${fileToUpload.size} bytes', DebugMessageType.info);

      // Verify we have a valid reference
      if (fileToUpload.reference is! EventMediaStorageReference) {
        _debugger.debPrint('Invalid reference type provided', DebugMessageType.error);
        throw GenericStorageException('Invalid reference type for event media upload');
      }

      final eventRef = fileToUpload.reference as EventMediaStorageReference;
      final eventId = eventRef.eventId;
      final index = eventRef.index;

      _debugger.debPrint('Event ID: $eventId, Index: $index', DebugMessageType.info);

      late final List<File> files;
      late final List<String> filenames;

      if (fileToUpload is ImageFileToUpload) {
        _debugger.debPrint('Processing image upload', DebugMessageType.info);
        files = [File(fileToUpload.filePath)];

        // Check if file exists
        if (!files[0].existsSync()) {
          _debugger.debPrint('Image file does not exist at path: ${fileToUpload.filePath}', DebugMessageType.error);
          throw GenericStorageException('Image file does not exist');
        }

        final extension = fileToUpload.filePath.split('.').last;
        filenames = ['image.$extension'];
        _debugger.debPrint('Created filename: ${filenames[0]}', DebugMessageType.info);
      } else if (fileToUpload is VideoFileToUpload) {
        _debugger.debPrint('Processing video upload with cover', DebugMessageType.info);
        final file = File(fileToUpload.filePath);
        final cover = File(fileToUpload.coverPath);

        // Check if files exist
        if (!file.existsSync()) {
          _debugger.debPrint('Video file does not exist at path: ${fileToUpload.filePath}', DebugMessageType.error);
          throw GenericStorageException('Video file does not exist');
        }

        if (!cover.existsSync()) {
          _debugger.debPrint('Cover file does not exist at path: ${fileToUpload.coverPath}', DebugMessageType.error);
          throw GenericStorageException('Cover file does not exist');
        }

        files = [file, cover];

        final videoExtension = fileToUpload.filePath.split('.').last;
        final coverExtension = fileToUpload.coverPath.split('.').last;

        filenames = ['video.$videoExtension', 'cover.$coverExtension'];
        _debugger.debPrint('Created filenames: ${filenames.join(", ")}', DebugMessageType.info);
      } else {
        _debugger.debPrint('Unsupported file type for upload', DebugMessageType.error);
        throw GenericStorageException('Invalid file type for upload');
      }

      // Create references
      final List<Reference> refs = [];
      _debugger.debPrint('Creating storage references for ${filenames.length} files', DebugMessageType.info);

      for (var i = 0; i < filenames.length; i++) {
        final ref = _storage.ref().child('events').child(eventId).child(index).child(filenames[i]);
        refs.add(ref);
        _debugger.debPrint('Created reference: ${ref.fullPath}', DebugMessageType.info);
      }

      // Log created paths for verification
      for (var ref in refs) {
        _debugger.debPrint('Storage reference: ${ref.fullPath}', DebugMessageType.fileTracking);
      }

      // Upload files
      final List<TaskSnapshot> uploadTasks = [];
      _debugger.debPrint('Starting file upload operations', DebugMessageType.uploading);

      if (fileToUpload is ImageFileToUpload) {
        _debugger.debPrint('Uploading image file', DebugMessageType.uploading);
        final uploadTask = await refs[0].putFile(
          files[0],
          SettableMetadata(contentType: fileToUpload.contentType),
        );
        uploadTasks.add(uploadTask);
        _debugger.debPrint('Image upload task completed with status: ${uploadTask.state}', DebugMessageType.done);
      } else if (fileToUpload is VideoFileToUpload) {
        _debugger.debPrint('Uploading video file', DebugMessageType.uploading);
        final uploadTask = await refs[0].putFile(
          files[0],
          SettableMetadata(contentType: fileToUpload.contentType),
        );
        uploadTasks.add(uploadTask);
        _debugger.debPrint('Video upload task completed with status: ${uploadTask.state}', DebugMessageType.done);

        _debugger.debPrint('Uploading cover file', DebugMessageType.uploading);
        final coverUploadTask = await refs[1].putFile(
          files[1],
          SettableMetadata(contentType: fileToUpload.coverContentType),
        );
        uploadTasks.add(coverUploadTask);
        _debugger.debPrint('Cover upload task completed with status: ${coverUploadTask.state}', DebugMessageType.done);
      }

      // Media is automatically processed by the Cloud Function validateEventMediaUploadedFile
      _debugger.debPrint('Getting download URLs for ${uploadTasks.length} uploaded files', DebugMessageType.info);
      final urls = await Future.wait(uploadTasks.map((task) => task.ref.getDownloadURL()));

      _debugger.debPrint('Media upload process completed successfully', DebugMessageType.done);
      _debugger.debPrint('Received ${urls.length} download URLs', DebugMessageType.info);

      return urls;
    } on FirebaseException catch (e) {
      _debugger.debPrint('Firebase error during upload: ${e.code} - ${e.message}', DebugMessageType.error);
      if (e.code == 'network-request-failed') {
        throw UnavailableStorageException('Storage service is unavailable');
      } else if (e.code == 'object-not-found') {
        throw ObjectNotFoundStorageException('Event not found');
      }
      _debugger.debPrint('Firebase error stack trace: ${e.stackTrace}', DebugMessageType.error);
      throw StorageServiceException('Error uploading event media: ${e.message}');
    } catch (e) {
      _debugger.debPrint('Unexpected error during upload: $e', DebugMessageType.error);
      _debugger.debPrint('Error stack trace: ${StackTrace.current}', DebugMessageType.error);
      if (e is StorageServiceException) {
        rethrow;
      }
      throw StorageServiceException('Error uploading event media: $e');
    }
  }

  Future<void> deleteEventMedia(String eventId) async {
    try {
      _debugger.debPrint('Starting event media deletion process', DebugMessageType.deleting);
      _debugger.debPrint('Event ID: $eventId', DebugMessageType.info);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        _debugger.debPrint('Starting Firestore transaction', DebugMessageType.database);

        final eventRef = FirebaseFirestore.instance.collection('events').doc(eventId);
        _debugger.debPrint('Checking event document exists', DebugMessageType.verifying);

        final eventDoc = await transaction.get(eventRef);

        if (!eventDoc.exists) {
          _debugger.debPrint('Event document not found in Firestore', DebugMessageType.error);
          throw ObjectNotFoundStorageException('Event not found');
        }
        _debugger.debPrint('Event document exists, proceeding with deletion', DebugMessageType.info);

        // Create the event storage reference
        final storageRef = _storage.ref().child('events').child(eventId);
        _debugger.debPrint('Created storage reference: ${storageRef.fullPath}', DebugMessageType.fileTracking);

        try {
          _debugger.debPrint('Listing files in storage path', DebugMessageType.fileTracking);
          final ListResult result = await storageRef.listAll();

          _debugger.debPrint('Found items in event folder:', DebugMessageType.fileTracking);
          _debugger.debPrint('- Prefixes count: ${result.prefixes.length}', DebugMessageType.fileTracking);
          for (var i = 0; i < result.prefixes.length; i++) {
            _debugger.debPrint('  Prefix $i: ${result.prefixes[i].fullPath}', DebugMessageType.fileTracking);
          }

          // Delete all media in the event folder (each prefix is a media item folder)
          int deletedFilesCount = 0;
          for (var prefix in result.prefixes) {
            _debugger.debPrint('Processing sub-folder: ${prefix.fullPath}', DebugMessageType.fileTracking);
            final nestedResult = await prefix.listAll();
            _debugger.debPrint('Found ${nestedResult.items.length} files in folder', DebugMessageType.fileTracking);

            for (var nestedItem in nestedResult.items) {
              _debugger.debPrint('Deleting file: ${nestedItem.fullPath}', DebugMessageType.fileDeleting);
              await nestedItem.delete();
              deletedFilesCount++;
            }
          }
          _debugger.debPrint('Deleted a total of $deletedFilesCount files', DebugMessageType.fileDeleting);

          // Update Firestore document to clear media
          _debugger.debPrint('Updating Firestore document to clear media array', DebugMessageType.updating);
          transaction.update(eventRef, {
            'media': {'media': []}
          });          
        } on FirebaseException catch (e) {
          _debugger.debPrint('Firebase error during deletion: ${e.code} - ${e.message}', DebugMessageType.error);
          if (e.code == 'unavailable') {
            throw UnavailableStorageException('Storage service is unavailable');
          }
          if (e.code != 'object-not-found') {
            _debugger.debPrint('Firebase error stack trace: ${e.stackTrace}', DebugMessageType.error);
            rethrow;
          }
          _debugger.debPrint('No event media files found to delete', DebugMessageType.warning);

          // Still update the Firestore document even if no files exist
          _debugger.debPrint('Updating Firestore document anyway', DebugMessageType.updating);
          transaction.update(eventRef, {
            'media': {'media': []}
          });
        }
      });

      _debugger.debPrint('Event media deletion process completed successfully', DebugMessageType.done);
    } on FirebaseException catch (e) {
      _debugger.debPrint('Firebase error during deletion transaction: ${e.code} - ${e.message}', DebugMessageType.error);
      if (e.code == 'unavailable') {
        throw UnavailableStorageException('Storage service is unavailable');
      }
      _debugger.debPrint('Firebase error stack trace: ${e.stackTrace}', DebugMessageType.error);
      throw StorageServiceException('Error deleting event media: ${e.message}');
    } catch (e) {
      _debugger.debPrint('Unexpected error during deletion: $e', DebugMessageType.error);
      _debugger.debPrint('Error stack trace: ${StackTrace.current}', DebugMessageType.error);
      if (e is StorageServiceException) {
        rethrow;
      }
      throw StorageServiceException('Error deleting event media: $e');
    }
  }
}
