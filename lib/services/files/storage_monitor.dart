import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:livit/utilities/debug/livit_debugger.dart';
import 'package:path_provider/path_provider.dart';

class StorageMonitor {
  static final StorageMonitor _instance = StorageMonitor._internal();
  factory StorageMonitor() => _instance;
  StorageMonitor._internal();

  static final LivitDebugger _debugger = const LivitDebugger('StorageMonitor');

  Timer? _monitorTimer;
  static const Duration monitorInterval = Duration(minutes: 15);

  void startPeriodicMonitoring() {
    stopPeriodicMonitoring();
    _monitorTimer = Timer.periodic(monitorInterval, (_) async {
      _debugger.debPrint('Monitoring storage', DebugMessageType.monitoring);
      final sizes = await getStorageInfo();
      _debugger.debPrint('Storage sizes: $sizes', DebugMessageType.info);
    });
  }

  void stopPeriodicMonitoring() {
    _monitorTimer?.cancel();
    _monitorTimer = null;
  }

  static Future<Map<String, double>> getStorageInfo() async {
    final Map<String, double> sizes = {};

    final appDir = await getApplicationDocumentsDirectory();
    final tempDir = await getTemporaryDirectory();
    final supportDir = await getApplicationSupportDirectory();
    final tempDirCustom = Directory('${appDir.parent.path}/tmp');

    // Convert all sizes to MB
    sizes['app_documents'] = await _getDirSize(appDir) / (1024 * 1024);
    sizes['temp'] = await _getDirSize(tempDir) / (1024 * 1024);
    sizes['support'] = await _getDirSize(supportDir) / (1024 * 1024);

    // Only check libraryDir on iOS
    if (Platform.isIOS) {
      final libraryDir = await getLibraryDirectory();
      sizes['library'] = await _getDirSize(libraryDir) / (1024 * 1024);
    }

    if (tempDirCustom.existsSync()) {
      sizes['temp_custom'] = await _getDirSize(tempDirCustom) / (1024 * 1024);
    }

    // Print all directory paths for debugging
    _debugger.debPrint('App Documents: ${appDir.path}', DebugMessageType.info);
    _debugger.debPrint('Temp: ${tempDir.path}', DebugMessageType.info);
    _debugger.debPrint('Support: ${supportDir.path}', DebugMessageType.info);
    if (Platform.isIOS) {
      final libraryDir = await getLibraryDirectory();
      _debugger.debPrint('Library: ${libraryDir.path}', DebugMessageType.info);
    }
    _debugger.debPrint('Temp custom: ${tempDirCustom.path}', DebugMessageType.info);

    return sizes;
  }

  static final bool debugAllFiles = true;

  static Future<int> _getDirSize(Directory dir) async {
    int size = 0;
    try {
      await for (final FileSystemEntity entity in dir.list(recursive: true)) {
        if (entity is File) {
          final length = await entity.length();
          if (debugAllFiles) {
            _debugger.debPrint('File: ${entity.path} - Size: ${length / (1024 * 1024)} MB', DebugMessageType.info);
          }
          size += length;
        }
      }
    } catch (e) {
      _debugger.debPrint('Error calculating size for ${dir.path}: $e', DebugMessageType.error);
    }
    return size;
  }
}
