import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class VideoCompressionService {
  static const int targetBitrate = 2000; // 2 Mbps
  static const String targetResolution = '1280x720'; // 720p

  static Future<String?> compressVideo({
    required String inputFilePath,
    void Function(double)? onProgress,
    int? customBitrate,
    String? customResolution,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final outputPath = path.join(
        tempDir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.mp4',
      );

      final bitrate = customBitrate ?? targetBitrate;
      final resolution = customResolution ?? targetResolution;

      // FFmpeg command for H.264 compression with quality preservation
      final command = '''
        -i $inputFilePath 
        -c:v libx264 
        -preset medium 
        -b:v ${bitrate}k 
        -vf scale=$resolution:force_original_aspect_ratio=decrease 
        -c:a aac 
        -b:a 128k 
        -movflags +faststart 
        $outputPath
      ''';

      final session = await FFmpegKit.execute(command.replaceAll('\n', ' '));
      final returnCode = await session.getReturnCode();

      if (!ReturnCode.isSuccess(returnCode)) {
        final logs = await session.getOutput();
        throw Exception('FFmpeg process failed: $logs');
      }

      if (!await File(outputPath).exists()) {
        throw Exception('Compressed file not found');
      }

      return outputPath;
    } catch (e) {
      print('Video compression failed: $e');
      return null;
    }
  }

  static Future<void> cleanup() async {
    final tempDir = await getTemporaryDirectory();
    final files = tempDir.listSync();
    for (var file in files) {
      if (file is File && file.path.contains('compressed_')) {
        await file.delete();
      }
    }
  }
} 