import 'package:livit/cloud_models/location/location_media_file.dart';

class LocationMedia {
  final LivitLocationMediaFile? mainFile;
  final List<LivitLocationMediaFile?>? secondaryFiles;

  LocationMedia({this.mainFile, this.secondaryFiles});

  Map<String, dynamic> toMap() {
    return {
      'mainFile': mainFile,
      'secondaryFiles': secondaryFiles,
    };
  }

  factory LocationMedia.fromMap(Map<String, dynamic> map) {
    return LocationMedia(
      mainFile: map['mainFile'] as LivitLocationMediaFile?,
      secondaryFiles: map['secondaryFiles'] as List<LivitLocationMediaFile?>?,
    );
  }

  LocationMedia copyWith({LivitLocationMediaFile? mainFile, List<LivitLocationMediaFile?>? secondaryFiles}) {
    return LocationMedia(
      mainFile: mainFile ?? this.mainFile,
      secondaryFiles: secondaryFiles ?? this.secondaryFiles,
    );
  }

  @override
  String toString() {
    return 'LocationMedia(mainFile: $mainFile, secondaryFiles: $secondaryFiles)';
  }
}
