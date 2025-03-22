import 'dart:io';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/statistics.dart';
import 'package:livit/services/firebase_storage/firebase_storage_constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

class VideoCompressionService {
  static const int targetBitrate = FirebaseStorageConstants.targetVideoBitrate;
  static const String targetResolution = FirebaseStorageConstants.targetVideoResolution;

  static Future<String?> compressVideo({
    required String inputFilePath,
    required void Function(Statistics) onProgress,
    required void Function(File file) onCompleted,
    void Function(Object, StackTrace)? onError,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final outputPath = path.join(
        tempDir.path,
        'livitmediacompressed_${DateTime.now().millisecondsSinceEpoch}.mp4',
      );

      // Parse resolution into width and height
      final dimensions = FirebaseStorageConstants.targetVideoResolution.split('x');
      final width = dimensions[0];
      final height = dimensions[1];

      // Fixed command with proper string concatenation and quotes
      final command = '-i "$inputFilePath" -c:v libx264 -preset fast -crf 23 '
          '-b:v ${FirebaseStorageConstants.targetVideoBitrate}k '
          '-maxrate ${(FirebaseStorageConstants.targetVideoBitrate * 1.5).round()}k '
          '-bufsize ${(FirebaseStorageConstants.targetVideoBitrate * 2).round()}k '
          '-vf scale=w=$width:h=$height:force_original_aspect_ratio=decrease,'
          'pad=w=$width:h=$height:x=(ow-iw)/2:y=(oh-ih)/2:color=black '
          '-profile:v high -level:v 4.0 -movflags +faststart '
          '-c:a aac -b:a 192k -ar 48000 -y '
          '"$outputPath"';

      debugPrint('🎥 [VideoCompressionService] Starting compression');
      debugPrint('📁 Input path: $inputFilePath');
      debugPrint('📁 Output path: $outputPath');
      debugPrint('⚙️ Command: $command');

      final session = await FFmpegKit.executeAsync(
        // "-y -i $inputFilePath -vcodec libx264 -crf 22 $outputPath",
        command,
        (session) async {
          final state = FFmpegKitConfig.sessionStateToString(await session.getState());
          final code = await session.getReturnCode();
          final logs = await session.getOutput();

          debugPrint('🎥 [VideoCompressionService] FFmpeg process completed');
          debugPrint('📊 State: $state');
          debugPrint('📊 Return code: $code');
          debugPrint('📝 Logs: $logs');

          if (ReturnCode.isSuccess(code)) {
            final outputFile = File(outputPath);
            if (await outputFile.exists()) {
              onCompleted(outputFile);
            } else {
              if (onError != null) {
                onError(
                  Exception('Output file not found at: $outputPath'),
                  StackTrace.current,
                );
              }
            }
          } else {
            if (onError != null) {
              onError(
                Exception('FFmpeg process exited with state $state and return code $code.\n$logs'),
                StackTrace.current,
              );
            }
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

      return outputPath;
    } catch (e) {
      debugPrint('❌ [VideoCompressionService] Video compression failed: $e');
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
