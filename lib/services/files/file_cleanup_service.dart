import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

class FileCleanupService {
  static final FileCleanupService _instance = FileCleanupService._internal();
  factory FileCleanupService() => _instance;
  FileCleanupService._internal();

  static const Duration _maxFileAge = Duration(minutes: 10);

  Future<void> cleanupTempFiles() async {
    debugPrint('🧹 [FileCleanupService] Cleaning up temp files');
    try {
      final tempDir = await getTemporaryDirectory();
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final tempDirCustom = Directory('${appDir.parent.path}/tmp');
        if (tempDirCustom.existsSync()) {
          await _cleanupDirectory(tempDirCustom);
        }
      } catch (e) {
        debugPrint('❌ [FileCleanupService] Error during cleanup: $e');
      }

      await _cleanupDirectory(tempDir);
    } catch (e) {
      debugPrint('❌ [FileCleanupService] Error during cleanup: $e');
    }
  }

  Future<void> _cleanupDirectory(Directory dir) async {
    try {
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          final stat = await entity.stat();
          late final Duration fileAge;

          final String name = entity.path.split('/').last.split('.').first;
          final List<String> nameParts = name.split('_');
          if (nameParts.length > 1) {
            final String typeString = nameParts[0];
            final String dateString = nameParts[1];
            if ((typeString == 'image' && dateString == 'picker') && dir.path != (await getTemporaryDirectory()).path) {
              debugPrint('🗑️ [FileCleanupService] Not deleting image_picker file: ${entity.path}, last accessed: ${stat.accessed}, size: ${await entity.length()/1024/1024} MB');
              fileAge = Duration.zero;
            } else {
              fileAge = DateTime.now().difference(stat.accessed);
            }
          } else {
            fileAge = DateTime.now().difference(stat.accessed);
          }

          if (fileAge > _maxFileAge) {
            debugPrint('🗑️ [FileCleanupService] Deleting old file: ${entity.path}, last accessed: ${stat.accessed}, age: $fileAge');
            await entity.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('❌ [FileCleanupService] Error cleaning directory ${dir.path}: $e');
    }
  }
}
