import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:livit/models/location/location_media.dart';
import 'package:livit/models/media/livit_media_file.dart';
import 'package:livit/services/firebase_storage/storage_service/file_to_upload.dart';
import 'package:livit/services/firebase_storage/storage_service/storage_reference.dart';
import 'package:livit/services/firebase_storage/storage_service/storage_service_exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livit/models/location/location.dart';

class StorageService {
  static final StorageService _shared = StorageService._sharedInstance();
  StorageService._sharedInstance();
  factory StorageService() => _shared;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<List<String>> uploadLocationMediaFile({required FileToUpload fileToUpload}) async {
    try {
      debugPrint('🔄 [StorageService] Uploading file: $fileToUpload');
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

      debugPrint('✅ [StorageService] File uploaded and Firestore updated');
      return downloadUrls;
    } on FirebaseException catch (e) {
      if (e.code == 'network-request-failed') {
        throw UnavailableStorageException('Storage service is unavailable');
      }
      rethrow;
    } catch (e) {
      debugPrint('❌ [StorageService] Error uploading file: $e');
      rethrow;
    }
  }

  Future<void> deleteFile(String url) async {
    await _storage.refFromURL(url).delete();
  }

  Future<void> deleteLocationMedia(String locationId) async {
    try {
      debugPrint('🔄 [StorageService] Deleting location media for ID: $locationId');

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final locationRef = FirebaseFirestore.instance.collection('locations').doc(locationId);
        final locationDoc = await transaction.get(locationRef);

        if (!locationDoc.exists) {
          throw ObjectNotFoundStorageException('Location not found');
        }

        // Create the correct storage reference
        final storageRef = _storage.ref().child('locations').child(locationId);
        debugPrint('🔍 [StorageService] Storage reference path: ${storageRef.fullPath}');

        try {
          final ListResult result = await storageRef.listAll();

          debugPrint('📁 [StorageService] Found items:');
          debugPrint('- Files: ${result.items.length}');
          debugPrint('- Prefixes: ${result.prefixes.length}');

          // Delete all files in the main directory
          for (var item in result.items) {
            debugPrint('🗑️ [StorageService] Deleting file: ${item.fullPath}');
            await item.delete();
          }

          for (var prefix in result.prefixes) {
            final nestedResult = await prefix.listAll();
            debugPrint('📁 [StorageService] Found nested items in ${prefix.fullPath}:');
            debugPrint('- Nested files: ${nestedResult.items.length}');

            for (var nestedItem in nestedResult.items) {
              debugPrint('🗑️ [StorageService] Deleting nested file: ${nestedItem.fullPath}');
              await nestedItem.delete();
            }
          }

          // Update Firestore document
          transaction.update(locationRef, {
            'media': LivitLocationMedia(files: []).toMap(),
          });

          debugPrint('✅ [StorageService] Location media deleted successfully');
        } on FirebaseException catch (e) {
          if (e.code == 'unavailable') {
            throw UnavailableStorageException('Storage service is unavailable');
          }
          if (e.code != 'object-not-found') {
            debugPrint('❌ [StorageService] Firebase error: ${e.code} - ${e.message}');
            rethrow;
          }
          debugPrint('⚠️ [StorageService] No files found to delete');
        }
      });

      debugPrint('✅ [StorageService] Location media deleted and document updated successfully');
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') {
        throw UnavailableStorageException('Storage service is unavailable');
      }
      rethrow;
    } catch (e) {
      debugPrint('❌ [StorageService] Error deleting location media: $e');
      rethrow;
    }
  }
}
