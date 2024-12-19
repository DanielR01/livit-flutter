import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/services/firebase_storage/bloc/storage_event.dart';
import 'package:livit/services/firebase_storage/bloc/storage_state.dart';
import 'package:livit/services/firebase_storage/storage_service.dart';

class StorageBloc extends Bloc<StorageEvent, StorageState> {
  final StorageService _storageService;

  StorageBloc()  : _storageService = StorageService(),
        super(const StorageInitial()) {
    on<UploadLocationMedia>(_onUploadLocationMedia);
  }

  Future<void> _onUploadLocationMedia(
    UploadLocationMedia event,
    Emitter<StorageState> emit,
  ) async {
    emit(const StorageUploading());
    try {
      List<String> urls = [];
      List<File> failedFiles = [];

      for (var file in event.files) {
        try {
          final url = await _storageService.uploadFile(
            file,
            event.locationId,
            event.type,
          );
          urls.add(url);
        } catch (e) {
          failedFiles.add(file);
        }

        // Emit progress
        emit(StorageUploading(
          progress: urls.length / event.files.length,
        ));
      }

      emit(StorageSuccess(urls: urls, failedFiles: failedFiles));
    } catch (e) {
      emit(StorageFailure(exception: e as Exception));
    }
  }
}
