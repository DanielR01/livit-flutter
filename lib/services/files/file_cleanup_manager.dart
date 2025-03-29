import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:livit/utilities/debug/livit_debugger.dart';
import 'file_cleanup_service.dart';

class FileCleanupManager {
  static final FileCleanupManager _instance = FileCleanupManager._internal();
  factory FileCleanupManager() => _instance;
  FileCleanupManager._internal();

  final LivitDebugger _debugger = const LivitDebugger('FileCleanupManager');

  Timer? _cleanupTimer;
  static const Duration cleanupInterval = Duration(minutes: 1);

  void startPeriodicCleanup() {
    stopPeriodicCleanup(); // Ensure no duplicate timers

    _cleanupTimer = Timer.periodic(cleanupInterval, (_) {
      _debugger.debPrint('Running periodic cleanup', DebugMessageType.info);
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
