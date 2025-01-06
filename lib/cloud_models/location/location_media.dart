import 'package:flutter/material.dart';
import 'package:livit/cloud_models/location/location_media_file.dart';
import 'package:livit/services/firestore_storage/firestore_storage/exceptions/locations_exceptions.dart';

class LivitLocationMedia {
  final LivitLocationMediaFile? mainFile;
  final List<LivitLocationMediaFile?>? secondaryFiles;

  LivitLocationMedia({this.mainFile, this.secondaryFiles});

  Map<String, dynamic> toMap() {
    return {
      'mainFile': mainFile?.toMap(),
      'secondaryFiles': secondaryFiles?.map((file) => file?.toMap()).toList(),
    };
  }

  factory LivitLocationMedia.fromMap(Map<String, dynamic> map) {
    try {
      debugPrint('📥 [LivitLocationMedia] Creating location media from map');
      return LivitLocationMedia(
        mainFile: map['mainFile'] != null ? LivitLocationMediaFile.fromMap(map['mainFile'] as Map<String, dynamic>) : null,
        secondaryFiles: map['secondaryFiles'] != null
            ? (map['secondaryFiles'] as List<dynamic>).map((file) => LivitLocationMediaFile.fromMap(file as Map<String, dynamic>)).toList()
            : null,
      );
    } catch (e) {
      debugPrint('❌ [LivitLocationMedia] Failed to create location media from map: $e');
      throw CouldNotCreateLocationMediaFromMapException(details: e.toString());
    }
  }

  LivitLocationMedia copyWith({LivitLocationMediaFile? mainFile, List<LivitLocationMediaFile?>? secondaryFiles}) {
    return LivitLocationMedia(
      mainFile: mainFile ?? this.mainFile,
      secondaryFiles: secondaryFiles ?? this.secondaryFiles,
    );
  }

  @override
  String toString() {
    return 'LocationMedia(mainFile: $mainFile, secondaryFiles: $secondaryFiles)';
  }
}
