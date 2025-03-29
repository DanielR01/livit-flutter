import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:livit/utilities/debug/livit_debugger.dart';

class TempFileManager {
  static final LivitDebugger _debugger = const LivitDebugger('temp_file_manager', isDebugEnabled: true);
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
        'size': await File(filePath).length() / 1024 / 1024,
        'isCompressed': isCompressed,
      }));

      await prefs.setStringList(_prefsKey, trackedFiles);
      _debugger.debPrint('Tracked new file: $filePath', DebugMessageType.fileTracking);
    } catch (e) {
      _debugger.debPrint('Error tracking temp file: $e', DebugMessageType.error);
    }
  }

  static Future<List<String>> _getTrackedFiles() async {
    final prefs = await SharedPreferences.getInstance();
    _debugger.debPrint('Tracked files: ${prefs.getStringList(_prefsKey)}', DebugMessageType.fileTracking);
    return prefs.getStringList(_prefsKey) ?? [];
  }

  static Future<void> cleanupOldFiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> trackedFiles = await _getTrackedFiles();
      final List<String> remainingFiles = [];
      final now = DateTime.now().millisecondsSinceEpoch;

      _debugger.debPrint('Starting cleanup of old files', DebugMessageType.fileCleaning);

      for (String fileData in trackedFiles) {
        try {
          final data = json.decode(fileData) as Map<String, dynamic>;
          final filePath = data['path'] as String;
          final timestamp = data['timestamp'] as int;

          if (now - timestamp > _maxFileAge.inMilliseconds) {
            final file = File(filePath);
            if (await file.exists()) {
              await file.delete();
              _debugger.debPrint('Deleted old file: $filePath', DebugMessageType.done);
            }
          } else {
            remainingFiles.add(fileData);
          }
        } catch (e) {
          _debugger.debPrint('Error processing file data: $e', DebugMessageType.error);
        }
      }

      await prefs.setStringList(_prefsKey, remainingFiles);
      _debugger.debPrint('Cleanup completed. Remaining files: ${remainingFiles.length}', DebugMessageType.done);
    } catch (e) {
      _debugger.debPrint('Error cleaning up temp files: $e', DebugMessageType.error);
    }
  }

  static Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        _debugger.debPrint('Deleted file: $filePath', DebugMessageType.done);
      }

      final prefs = await SharedPreferences.getInstance();
      final List<String> trackedFiles = await _getTrackedFiles();
      final List<String> remainingFiles = trackedFiles.where((fileData) {
        final data = json.decode(fileData) as Map<String, dynamic>;
        return data['path'] != filePath;
      }).toList();

      await prefs.setStringList(_prefsKey, remainingFiles);
    } catch (e) {
      _debugger.debPrint('Error deleting temp file: $e', DebugMessageType.error);
    }
  }

  static Future<void> cleanupAllFiles() async {
    _debugger.debPrint('Starting cleanup of all files', DebugMessageType.fileCleaning);
    try {
      final List<String> trackedFiles = await _getTrackedFiles();

      for (String fileData in trackedFiles) {
        try {
          final data = json.decode(fileData) as Map<String, dynamic>;
          final filePath = data['path'] as String;
          final file = File(filePath);
          if (await file.exists()) {
            await file.delete();
            _debugger.debPrint('Deleted file: $filePath', DebugMessageType.done);
          }
        } catch (e) {
          _debugger.debPrint('Error deleting file: $e', DebugMessageType.error);
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKey, []);
      _debugger.debPrint('All files cleaned up', DebugMessageType.done);
    } catch (e) {
      _debugger.debPrint('Error cleaning up all temp files: $e', DebugMessageType.error);
    }
  }

  // Start periodic cleanup
  static void startPeriodicCleanup() {
    stopPeriodicCleanup(); // Cancel any existing timer

    _cleanupTimer = Timer.periodic(_cleanupInterval, (_) {
      _debugger.debPrint('Running periodic cleanup (every 5 minutes)', DebugMessageType.scheduling);
      cleanupOldFiles();
    });

    _debugger.debPrint('Started periodic cleanup timer', DebugMessageType.done);
  }

  // Stop periodic cleanup
  static void stopPeriodicCleanup() {
    if (_cleanupTimer != null && _cleanupTimer!.isActive) {
      _cleanupTimer!.cancel();
      _cleanupTimer = null;
      _debugger.debPrint('Stopped periodic cleanup timer', DebugMessageType.done);
    }
  }
}
