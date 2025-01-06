import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

class StorageMonitor {
  static final StorageMonitor _instance = StorageMonitor._internal();
  factory StorageMonitor() => _instance;
  StorageMonitor._internal();

  Timer? _monitorTimer;
  static const Duration monitorInterval = Duration(minutes: 10);

  void startPeriodicMonitoring() {
    stopPeriodicMonitoring();
    _monitorTimer = Timer.periodic(monitorInterval, (_) async {
      final sizes = await getStorageInfo();
      debugPrint('[StorageMonitor] Storage sizes: $sizes');
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
    debugPrint('[StorageMonitor] App Documents: ${appDir.path}');
    debugPrint('[StorageMonitor] Temp: ${tempDir.path}');
    debugPrint('[StorageMonitor] Support: ${supportDir.path}');
    if (Platform.isIOS) {
      final libraryDir = await getLibraryDirectory();
      debugPrint('[StorageMonitor] Library: ${libraryDir.path}');
    }
    debugPrint('[StorageMonitor] Temp custom: ${tempDirCustom.path}');

    return sizes;
  }

  static final bool debugAllFiles = false;

  static Future<int> _getDirSize(Directory dir) async {
    int size = 0;
    try {
      await for (final FileSystemEntity entity in dir.list(recursive: true)) {
        if (entity is File) {
          final length = await entity.length();
          if (debugAllFiles) {
            debugPrint('[StorageMonitor] File: ${entity.path} - Size: ${length / (1024 * 1024)} MB');
          }
          size += length;
        }
      }
    } catch (e) {
      debugPrint('[StorageMonitor] Error calculating size for ${dir.path}: $e');
    }
    return size;
  }
}
