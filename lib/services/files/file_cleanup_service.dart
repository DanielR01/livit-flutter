import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

class FileCleanupService {
  static const List<String> _cleanupDirectories = [
    'temp',
    'cache',
    'downloads',
  ];

  static final FileCleanupService _instance = FileCleanupService._internal();
  factory FileCleanupService() => _instance;
  FileCleanupService._internal();

  static const Duration _maxFileAge = Duration(minutes: 1);

  Future<void> cleanupTempFiles() async {
    debugPrint('Cleaning up temp files');
    try {
      final appDir = await getApplicationDocumentsDirectory();
      debugPrint('App directory: ${appDir.path}');
      final tempDir = await getTemporaryDirectory();
      debugPrint('Temp directory: ${tempDir.path}');

      for (String dirName in _cleanupDirectories) {
        await _cleanupDirectory('${appDir.path}/$dirName');
        await _cleanupDirectory('${tempDir.path}/$dirName');
      }
    } catch (e) {
      debugPrint('Error during cleanup: $e');
    }
  }

  Future<void> _cleanupDirectory(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      return;
    }

    try {
      await for (final entity in dir.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          final fileAge = DateTime.now().difference(stat.modified);
          if (fileAge > _maxFileAge) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('Error cleaning directory $path: $e');
    }
  }
}
