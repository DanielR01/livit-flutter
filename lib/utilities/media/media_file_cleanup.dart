import 'dart:io';

import 'package:flutter/material.dart';
import 'package:livit/cloud_models/location/location_media_file.dart';

class MediaFileCleanup {
  static Future<void> deleteFile(File? file) async {
    if (file != null && await file.exists()) {
      try {
        await file.delete();
      } catch (e) {
        debugPrint('Error deleting file: $e');
      }
    }
  }

  static Future<void> deleteFileByPath(String? filePath) async {
    if (filePath == null) return;
    debugPrint('Deleting file: $filePath');
    await deleteFile(File(filePath));
  }

  static Future<void> cleanupLocationMediaFile(LivitLocationMediaFile? mediaFile) async {
    if (mediaFile?.filePath == null) return;

    await deleteFile(File(mediaFile!.filePath!));

    if (mediaFile is LivitLocationMediaVideo) {
      if (mediaFile.cover.filePath == null) return;
      await deleteFile(File(mediaFile.cover.filePath!));
    }
  }
}
