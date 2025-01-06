enum LivitLocationMediaType {
  image,
  video,
}

class LivitLocationMediaFile {
  final LivitLocationMediaType type;
  final String? url;
  final String? filePath;

  LivitLocationMediaFile({required this.type, required this.url, required this.filePath});

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'url': url,
    };
  }

  factory LivitLocationMediaFile.fromMap(Map<String, dynamic> map) {
    return LivitLocationMediaFile(
      type: LivitLocationMediaType.values.firstWhere((e) => e.name == map['type']),
      url: map['url'],
      filePath: null,
    );
  }

  LivitLocationMediaFile copyWith({String? url, String? filePath}) {
    return LivitLocationMediaFile(
      type: type,
      url: url ?? this.url,
      filePath: filePath ?? this.filePath,
    );
  }

  @override
  String toString() {
    return 'LivitLocationMediaFile(type: $type, url: $url, filePath: $filePath)';
  }
}

class LivitLocationMediaImage extends LivitLocationMediaFile {
  LivitLocationMediaImage({required super.url, required super.filePath}) : super(type: LivitLocationMediaType.image);

  factory LivitLocationMediaImage.fromMap(Map<String, dynamic> map) {
    return LivitLocationMediaImage(
      url: map['url'],
      filePath: null,
    );
  }

  @override
  String toString() {
    return 'LivitLocationMediaImage(url: $url, filePath: $filePath)';
  }

  @override
  LivitLocationMediaImage copyWith({String? url, String? filePath}) {
    return LivitLocationMediaImage(url: url ?? this.url, filePath: filePath ?? this.filePath);
  }
}

class LivitLocationMediaVideo extends LivitLocationMediaFile {
  final LivitLocationMediaImage cover;

  LivitLocationMediaVideo({required super.url, required super.filePath, required this.cover}) : super(type: LivitLocationMediaType.video);

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
      filePath: null,
      cover: LivitLocationMediaImage.fromMap(map['cover']),
    );
  }

  @override
  String toString() {
    return 'LivitLocationMediaVideo(url: $url, filePath: $filePath, cover: $cover)';
  }

  @override
  LivitLocationMediaVideo copyWith({String? url, String? filePath, LivitLocationMediaImage? cover}) {
    return LivitLocationMediaVideo(
      url: url ?? this.url,
      filePath: filePath ?? this.filePath,
      cover: cover ?? this.cover,
    );
  }
}
