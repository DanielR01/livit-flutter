import 'package:livit/models/media/location_media_file.dart';

class ProductMedia {
  final List<LivitMediaFile?> media;

  ProductMedia({required this.media});

  Map<String, dynamic> toMap() {
    return {
      'files': media.map((file) => file?.toMap()).toList(),
    };
  }

  factory ProductMedia.fromList(List<dynamic> list) {
    return ProductMedia(
      media: list.map((mediaFile) => mediaFile != null ? LivitMediaFile.fromMap(mediaFile) : null).toList(),
    );
  }

  ProductMedia copyWith(media) {
    return ProductMedia(
      media: media ?? this.media,
    );
  }

  @override
  String toString() {
    return 'ProductMedia(media: $media)';
  }
}
