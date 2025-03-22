import 'package:flutter/cupertino.dart';

enum LivitMediaType {
  image,
  video,
}

class LivitMediaFile {
  final LivitMediaType type;
  final String? url;
  final String? filePath;

  LivitMediaFile({required this.type, required this.url, required this.filePath});

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'url': url,
    };
  }

  factory LivitMediaFile.fromMap(Map<String, dynamic> map) {
    debugPrint('🛠️ [LivitMediaFile] fromMap: $map');
    if (map['type'] == LivitMediaType.image.name) {
      return LivitMediaImage.fromMap(map);
    } else if (map['type'] == LivitMediaType.video.name) {
      return LivitMediaVideo.fromMap(map);
    }
    throw Exception('Invalid media type: ${map['type']}');
  }

  LivitMediaFile copyWith({String? url, String? filePath}) {
    return LivitMediaFile(
      type: type,
      url: url ?? this.url,
      filePath: filePath ?? this.filePath,
    );
  }

  @override
  String toString() {
    return 'LivitMediaFile(type: $type, url: $url, filePath: $filePath)';
  }
}

class LivitMediaImage extends LivitMediaFile {
  LivitMediaImage({required super.url, required super.filePath}) : super(type: LivitMediaType.image);

  factory LivitMediaImage.fromMap(Map<String, dynamic> map) {
    debugPrint('🛠️ [LivitMediaImage] fromMap: $map');
    return LivitMediaImage(
      url: map['url'],
      filePath: null,
    );
  }

  @override
  String toString() {
    return 'LivitMediaImage(url: $url, filePath: $filePath)';
  }

  @override
  LivitMediaImage copyWith({String? url, String? filePath}) {
    return LivitMediaImage(url: url ?? this.url, filePath: filePath ?? this.filePath);
  }
}

class LivitMediaVideo extends LivitMediaFile {
  final LivitMediaImage cover;

  LivitMediaVideo({required super.url, required super.filePath, required this.cover}) : super(type: LivitMediaType.video);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'cover': cover.toMap(),
    };
  }

  factory LivitMediaVideo.fromMap(Map<String, dynamic> map) {
    debugPrint('🛠️ [LivitMediaVideo] fromMap: $map');
    return LivitMediaVideo(
      url: map['url'],
      filePath: null,
      cover: LivitMediaImage.fromMap(map['cover']),
    );
  }

  @override
  String toString() {
    return 'LivitMediaVideo(url: $url, filePath: $filePath, cover: $cover)';
  }

  @override
  LivitMediaVideo copyWith({String? url, String? filePath, LivitMediaImage? cover}) {
    return LivitMediaVideo(
      url: url ?? this.url,
      filePath: filePath ?? this.filePath,
      cover: cover ?? this.cover,
    );
  }
}
