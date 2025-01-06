import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:ffmpeg_kit_flutter/statistics.dart';
import 'package:livit/services/firebase_storage/firebase_storage_constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class VideoCompressionService {
  static const int targetBitrate = FirebaseStorageConstants.targetVideoBitrate;
  static const String targetResolution = FirebaseStorageConstants.targetVideoResolution;

  static Future<String?> compressVideo({
    required String inputFilePath,
    required void Function(Statistics) onProgress,
    required void Function(File file) onCompleted,
    void Function(Object, StackTrace)? onError,
    int? customBitrate,
    String? customResolution,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final outputPath = path.join(
        tempDir.path,
        'compressed_${DateTime.now().day}_${DateTime.now().month}_${DateTime.now().year}_${DateTime.now().hour}_${DateTime.now().minute}_${DateTime.now().millisecondsSinceEpoch}.mp4',
      );

      final bitrate = customBitrate ?? targetBitrate;
      final resolution = customResolution ?? targetResolution;

      // Add progress parameter to command
      final command = '-i "$inputFilePath" '
          '-c:v h264 '
          '-b:v ${bitrate}k '
          '-vf scale=$resolution:force_original_aspect_ratio=decrease '
          '-c:a aac '
          '-b:a 128k '
          '-movflags +faststart '
          '-progress pipe:1 '
          '"$outputPath"';

      final session = await FFmpegKit.executeAsync(command, 
      (session) async {
        final state = FFmpegKitConfig.sessionStateToString(await session.getState());
        final code = await session.getReturnCode();

        if (ReturnCode.isSuccess(code)) {
          onCompleted(File(outputPath));
        } else {
          if (onError != null) {
            onError(
              Exception('FFmpeg process exited with state $state and return code $code.\n${await session.getOutput()}'),
              StackTrace.current,
            );
          }
          return;
        }
      },
      null,
      onProgress,
      );

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
