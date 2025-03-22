import 'package:flutter/cupertino.dart';
import 'package:livit/models/media/livit_media_file.dart';

class EventMedia {
  final List<LivitMediaFile> media;

  EventMedia({required this.media});

  Map<String, dynamic> toMap() {
    return {
      'files': media.map((file) => file.toMap()).toList(),
    };
  }

  factory EventMedia.fromMap(Map<String, dynamic> map) {
    debugPrint('🛠️ [EventMedia] fromMap: $map');
    return EventMedia(
      media: (map['files'] as List<dynamic>?)
              ?.map((mediaFile) => LivitMediaFile.fromMap(mediaFile as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  EventMedia copyWith(media) {
    return EventMedia(
      media: media ?? this.media,
    );
  }

  @override
  String toString() {
    return 'EventMedia(media: $media)';
  }
}
