import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

class StorageMonitor {
  static Future<Map<String, int>> getStorageInfo() async {
    final Map<String, int> sizes = {};
    
    final appDir = await getApplicationDocumentsDirectory();
    final tempDir = await getTemporaryDirectory();
    final cacheDir = await getTemporaryDirectory();
    
    sizes['app'] = await _getDirSize(appDir);
    sizes['temp'] = await _getDirSize(tempDir);
    sizes['cache'] = await _getDirSize(cacheDir);
    
    return sizes;
  }

  static Future<int> _getDirSize(Directory dir) async {
    int size = 0;
    try {
      await for (final FileSystemEntity entity in dir.list(recursive: true)) {
        if (entity is File) {
          size += await entity.length();
        }
      }
    } catch (e) {
      debugPrint('Error calculating size for ${dir.path}: $e');
    }
    return size;
  }
}