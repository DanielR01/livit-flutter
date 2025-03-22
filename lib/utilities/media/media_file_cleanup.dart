import 'dart:io';

import 'package:flutter/material.dart';
import 'package:livit/models/media/livit_media_file.dart';

class MediaFileCleanup {
  static Future<void> deleteFile(File? file) async {
    if (file != null && await file.exists()) {
      try {
        debugPrint('🗑️ [MediaFileCleanup] Deleting file: ${file.path}');
        await file.delete();
      } catch (e) {
        debugPrint('🗑️ [MediaFileCleanup] Error deleting file: $e');
      }
    } else {
      debugPrint('🗑️ [MediaFileCleanup] File cannot be deleted because it does not exist: ${file?.path}');
    }
  }

  static Future<void> deleteFileByPath(String? filePath) async {
    if (filePath == null) return;
    await deleteFile(File(filePath));
  }

  static Future<void> cleanupLocationMediaFile(LivitMediaFile? mediaFile) async {
    if (mediaFile?.filePath == null) return;

    await deleteFile(File(mediaFile!.filePath!));

    if (mediaFile is LivitMediaVideo) {
      if (mediaFile.cover.filePath == null) return;
      await deleteFile(File(mediaFile.cover.filePath!));
    }
  }
}
