import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

class FileCleanupService {
  static final FileCleanupService _instance = FileCleanupService._internal();
  factory FileCleanupService() => _instance;
  FileCleanupService._internal();

  static const Duration _maxFileAge = Duration(hours: 12);

  Future<void> cleanupTempFiles() async {
    debugPrint('Cleaning up temp files');
    try {
      final tempDir = await getTemporaryDirectory();
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final tempDirCustom = Directory('${appDir.parent.path}/tmp');
        if (tempDirCustom.existsSync()) {
          await _cleanupDirectory(tempDirCustom);
        }
      } catch (e) {
        debugPrint('Error during cleanup: $e');
      }
      
      await _cleanupDirectory(tempDir);
    } catch (e) {
      debugPrint('Error during cleanup: $e');
    }
  }

  Future<void> _cleanupDirectory(Directory dir) async {
    try {
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          final stat = await entity.stat();
          final fileAge = DateTime.now().difference(stat.modified);
          if (fileAge > _maxFileAge) {
            debugPrint('Deleting old file: ${entity.path}');
            await entity.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('Error cleaning directory ${dir.path}: $e');
    }
  }
}
