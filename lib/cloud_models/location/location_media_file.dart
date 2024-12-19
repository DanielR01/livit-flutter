import 'dart:io';

enum LivitLocationMediaType {
  image,
  video,
}

class LivitLocationMediaFile {
  final LivitLocationMediaType type;
  final String? url;
  final File? file;

  LivitLocationMediaFile({required this.type, required this.url, required this.file});

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'url': url,
      'file': file,
    };
  } 

  factory LivitLocationMediaFile.fromMap(Map<String, dynamic> map) {
    return LivitLocationMediaFile(
      type: map['type'],
      url: map['url'],
      file: map['file'] as File?,
    );
  }

  LivitLocationMediaFile copyWith({String? url, File? file}) {
    return LivitLocationMediaFile(
      type: type,
      url: url ?? this.url,
      file: file ?? this.file,
    );
  }

  @override
  String toString() {
    return 'LivitLocationMediaFile(type: $type, url: $url, file: $file)';
  }
}

class LivitLocationMediaImage extends LivitLocationMediaFile {
  LivitLocationMediaImage({ required super.url, required super.file}) : super(type: LivitLocationMediaType.image);

  factory LivitLocationMediaImage.fromMap(Map<String, dynamic> map) {
    return LivitLocationMediaImage(
      url: map['url'],
      file: map['file'] as File?,
    );
  }

  @override
  String toString() {
    return 'LivitLocationMediaImage(url: $url, file: $file)';
  }
}

class LivitLocationMediaVideo extends LivitLocationMediaFile {
  final LivitLocationMediaImage cover;

  LivitLocationMediaVideo({ required super.url, required super.file, required this.cover}) : super(type: LivitLocationMediaType.video);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'cover': cover.toMap(),
    };
  }

  factory LivitLocationMediaVideo.fromMap(Map<String, dynamic> map) {
    return LivitLocationMediaVideo(
      url: map['url'],
      file: map['file'] as File?,
      cover: LivitLocationMediaImage.fromMap(map['cover']),
    );
  }

  @override
  String toString() {
    return 'LivitLocationMediaVideo(url: $url, file: $file, cover: $cover)';
  }
}