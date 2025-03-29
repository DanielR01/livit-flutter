import 'package:livit/models/media/livit_media_file.dart';
import 'package:livit/utilities/debug/livit_debugger.dart';

final _debugger = LivitDebugger('event_media');

class EventMedia {
  final List<LivitMediaFile> media;

  EventMedia({required this.media});

  Map<String, dynamic> toMap() {
    return {
      'files': media.map((file) => file.toMap()).toList(),
    };
  }

  factory EventMedia.fromMap(Map<String, dynamic> map) {
    _debugger.debPrint('fromMap: $map', DebugMessageType.reading);
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
