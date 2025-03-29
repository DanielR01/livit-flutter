import 'dart:io';
import 'package:livit/models/media/livit_media_file.dart';
import 'package:livit/utilities/debug/livit_debugger.dart';

class MediaFileCleanup {
  static const _debugger = LivitDebugger('MediaFileCleanup');

  static Future<void> deleteFile(File? file) async {
    if (file != null && await file.exists()) {
      try {
        _debugger.debPrint('Deleting file: ${file.path}', DebugMessageType.fileDeleting);
        await file.delete();
      } catch (e) {
        _debugger.debPrint('Error deleting file: $e', DebugMessageType.error);
      }
    } else {
      _debugger.debPrint('File cannot be deleted because it does not exist: ${file?.path}', DebugMessageType.warning);
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
