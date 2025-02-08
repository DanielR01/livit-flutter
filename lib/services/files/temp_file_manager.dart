import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TempFileManager {
  static const String _prefsKey = 'temp_files';

  static Future<void> trackFile(String filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      final List<String> trackedFiles = await _getTrackedFiles();

      trackedFiles.add(json.encode({
        'path': filePath,
        'timestamp': now,
      }));

      await prefs.setStringList(_prefsKey, trackedFiles);
      debugPrint('📝 [TempFileManager] Tracked new file: $filePath');
    } catch (e) {
      debugPrint('❌ [TempFileManager] Error tracking temp file: $e');
    }
  }

  static Future<List<String>> _getTrackedFiles() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_prefsKey) ?? [];
  }

  static Future<void> cleanupOldFiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> trackedFiles = await _getTrackedFiles();
      final List<String> remainingFiles = [];
      final now = DateTime.now().millisecondsSinceEpoch;

      debugPrint('🧹 [TempFileManager] Starting cleanup of old files');

      for (String fileData in trackedFiles) {
        try {
          final data = json.decode(fileData) as Map<String, dynamic>;
          final filePath = data['path'] as String;
          final timestamp = data['timestamp'] as int;

          if (now - timestamp > const Duration(hours: 1).inMilliseconds) {
            final file = File(filePath);
            if (await file.exists()) {
              await file.delete();
              debugPrint('🗑️ [TempFileManager] Deleted old file: $filePath');
            }
          } else {
            remainingFiles.add(fileData);
          }
        } catch (e) {
          debugPrint('⚠️ [TempFileManager] Error processing file data: $e');
        }
      }

      await prefs.setStringList(_prefsKey, remainingFiles);
      debugPrint('✅ [TempFileManager] Cleanup completed. Remaining files: ${remainingFiles.length}');
    } catch (e) {
      debugPrint('❌ [TempFileManager] Error cleaning up temp files: $e');
    }
  }

  static Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('🗑️ [TempFileManager] Deleted file: $filePath');
      }

      final prefs = await SharedPreferences.getInstance();
      final List<String> trackedFiles = await _getTrackedFiles();
      final List<String> remainingFiles = trackedFiles.where((fileData) {
        final data = json.decode(fileData) as Map<String, dynamic>;
        return data['path'] != filePath;
      }).toList();

      await prefs.setStringList(_prefsKey, remainingFiles);
    } catch (e) {
      debugPrint('❌ [TempFileManager] Error deleting temp file: $e');
    }
  }

  static Future<void> cleanupAllFiles() async {
    try {
      debugPrint('🧹 [TempFileManager] Starting cleanup of all files');
      final List<String> trackedFiles = await _getTrackedFiles();

      for (String fileData in trackedFiles) {
        try {
          final data = json.decode(fileData) as Map<String, dynamic>;
          final filePath = data['path'] as String;
          final file = File(filePath);
          if (await file.exists()) {
            await file.delete();
            debugPrint('🗑️ [TempFileManager] Deleted file: $filePath');
          }
        } catch (e) {
          debugPrint('⚠️ [TempFileManager] Error deleting file: $e');
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKey, []);
      debugPrint('✅ [TempFileManager] All files cleaned up');
    } catch (e) {
      debugPrint('❌ [TempFileManager] Error cleaning up all temp files: $e');
    }
  }
}
