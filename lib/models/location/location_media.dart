import 'package:flutter/material.dart';
import 'package:livit/models/media/livit_media_file.dart';
import 'package:livit/services/firestore_storage/firestore_storage/exceptions/locations_exceptions.dart';

class LivitLocationMedia {
  final List<LivitMediaFile?>? files;

  LivitLocationMedia({this.files});

  Map<String, dynamic> toMap() {
    return {
      'files': files?.map((file) => file?.toMap()).toList(),
    };
  }

  factory LivitLocationMedia.fromMap(Map<String, dynamic> map) {
    try {
      debugPrint('📥 [LivitLocationMedia] Creating location media from map');
      return LivitLocationMedia(
        files: map['files'] != null
            ? (map['files'] as List<dynamic>).map((file) => LivitMediaFile.fromMap(file as Map<String, dynamic>)).toList()
            : [],
      );
    } catch (e) {
      debugPrint('❌ [LivitLocationMedia] Failed to create location media from map: $e');
      throw CouldNotCreateLocationMediaFromMapException(details: e.toString());
    }
  }

  factory LivitLocationMedia.fromList(List<dynamic> list) {
    return LivitLocationMedia(
      files: list.map((mediaFile) => mediaFile != null ? LivitMediaFile.fromMap(mediaFile) : null).toList(),
    );
  }

  LivitLocationMedia copyWith({List<LivitMediaFile?>? files}) {
    return LivitLocationMedia(
      files: files ?? this.files,
    );
  }

  @override
  String toString() {
    return 'LocationMedia(media: $files)';
  }
}
