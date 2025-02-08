import 'package:livit/services/firebase_storage/storage_service/storage_reference.dart';

abstract class FileToUpload {
  final String filePath;
  final String contentType;
  final StorageReference reference;
  final int size;

  FileToUpload({required this.filePath, required this.contentType, required this.reference, required this.size});
}

class VideoFileToUpload extends FileToUpload {
  final String coverPath;
  final String coverContentType;
  final int coverSize;  
  VideoFileToUpload({required this.coverPath, required this.coverContentType, required this.coverSize, required super.filePath, required super.contentType, required super.reference, required super.size});

  @override
  String toString() {
    return 'VideoFileToUpload(coverPath: $coverPath, coverContentType: $coverContentType, coverSize: $coverSize, filePath: $filePath, contentType: $contentType, reference: $reference, size: $size)';
  }
}

class ImageFileToUpload extends FileToUpload {
  ImageFileToUpload({required super.filePath, required super.contentType, required super.reference, required super.size});

  @override
  String toString() {
    return 'ImageFileToUpload(filePath: $filePath, contentType: $contentType, reference: $reference, size: $size)';
  }
}

