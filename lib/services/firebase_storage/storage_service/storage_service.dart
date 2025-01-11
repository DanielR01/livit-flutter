import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:livit/services/firebase_storage/storage_service/storage_service_exceptions.dart';

class StorageService {
  static final StorageService _shared = StorageService._sharedInstance();
  StorageService._sharedInstance();
  factory StorageService() => _shared;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFileWithSignedUrl(String filePath, String signedUrl, String contentType) async {
    try {
      debugPrint('🔄 [StorageService] Uploading file');
      final response = await HttpClient().putUrl(Uri.parse(signedUrl)).then((request) async {
        request.headers.contentType = ContentType(contentType.split('/')[0], contentType.split('/')[1]);
        //request.headers.contentLength = await file.length();
        await request.addStream(File(filePath).openRead());
        return request.close();
      });

      if (response.statusCode != 200) {
        throw Exception('Failed to upload file: ${response.statusCode}, ${response.reasonPhrase}');
      }
      debugPrint('✅ [StorageService] File uploaded successfully');
      return signedUrl.split('?')[0]; // Return the clean URL without query params
    } catch (e) {
      debugPrint('❌ [StorageService] Error uploading file: $e');
      throw Exception('Error uploading file: $e');
    }
  }

  Future<void> deleteFile(String url) async {
    await _storage.refFromURL(url).delete();
  }

  Future<void> deleteLocationMedia(String locationId) async {
    try {
      debugPrint('🔄 [StorageService] Deleting location media');
      await _storage.refFromURL('gs://thelivitapp.appspot.com/locations/$locationId').delete();
      debugPrint('✅ [StorageService] Location media deleted');
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        throw ObjectNotFoundStorageException('Object not found');
      }
    } catch (e) {
      debugPrint('❌ [StorageService] Error deleting location media: $e');
      throw Exception('Error deleting location media: $e');
    }
  }
}
