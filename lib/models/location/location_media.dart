import 'package:flutter/material.dart';
import 'package:livit/models/media/livit_media_file.dart';
import 'package:livit/services/firestore_storage/firestore_storage/exceptions/locations_exceptions.dart';
import 'package:livit/utilities/debug/livit_debugger.dart';

final _debugger = LivitDebugger('location_media', isDebugEnabled: false);

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
      _debugger.debPrint('Creating location media from map', DebugMessageType.reading);
      return LivitLocationMedia(
        files: map['files'] != null
            ? (map['files'] as List<dynamic>).map((file) => LivitMediaFile.fromMap(file as Map<String, dynamic>)).toList()
            : [],
      );
    } catch (e) {
      _debugger.debPrint('Failed to create location media from map: $e', DebugMessageType.error);
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
