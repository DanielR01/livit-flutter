import 'dart:async';
import 'package:flutter/foundation.dart';
import 'file_cleanup_service.dart';

class FileCleanupManager {
  static final FileCleanupManager _instance = FileCleanupManager._internal();
  factory FileCleanupManager() => _instance;
  FileCleanupManager._internal();

  Timer? _cleanupTimer;
  static const Duration cleanupInterval = Duration(minutes: 10);

  void startPeriodicCleanup() {
    stopPeriodicCleanup(); // Ensure no duplicate timers
    
    _cleanupTimer = Timer.periodic(cleanupInterval, (_) {
      debugPrint('Running periodic cleanup');
      FileCleanupService().cleanupTempFiles();
    });
  }

  void stopPeriodicCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }

  void cleanupOnAppPause() {
    FileCleanupService().cleanupTempFiles();
  }
} 