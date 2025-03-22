import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class TempFileManager {
  static const String _prefsKey = 'temp_files';
  static const Duration _cleanupInterval = Duration(minutes: 10);
  static const Duration _maxFileAge = Duration(hours: 36);
  static Timer? _cleanupTimer;

  static Future<void> trackFile(String filePath, bool isCompressed) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      final List<String> trackedFiles = await _getTrackedFiles();

      trackedFiles.add(json.encode({
        'path': filePath,
        'timestamp': now,
        'size': await File(filePath).length(),
        'isCompressed': isCompressed,
      }));

      await prefs.setStringList(_prefsKey, trackedFiles);
      debugPrint('📝 [TempFileManager] Tracked new file: $filePath');
    } catch (e) {
      debugPrint('❌ [TempFileManager] Error tracking temp file: $e');
    }
  }

  static Future<List<String>> _getTrackedFiles() async {
    final prefs = await SharedPreferences.getInstance();
    debugPrint('📝 [TempFileManager] Tracked files: ${prefs.getStringList(_prefsKey)}');
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

          if (now - timestamp > _maxFileAge.inMilliseconds) {
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

  // Start periodic cleanup
  static void startPeriodicCleanup() {
    stopPeriodicCleanup(); // Cancel any existing timer

    _cleanupTimer = Timer.periodic(_cleanupInterval, (_) {
      debugPrint('🧹 [TempFileManager] Running periodic cleanup (every 5 minutes)');
      cleanupOldFiles();
    });

    debugPrint('✅ [TempFileManager] Started periodic cleanup timer');
  }

  // Stop periodic cleanup
  static void stopPeriodicCleanup() {
    if (_cleanupTimer != null && _cleanupTimer!.isActive) {
      _cleanupTimer!.cancel();
      _cleanupTimer = null;
      debugPrint('🛑 [TempFileManager] Stopped periodic cleanup timer');
    }
  }
}
