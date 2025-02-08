import 'dart:io';

import 'package:livit/constants/enums.dart';
import 'package:livit/services/exceptions/base_exception.dart';
import 'package:livit/services/firebase_storage/bloc/storage_bloc_exception.dart';

abstract class StorageState {
  const StorageState();
}

class StorageInitial extends StorageState {
  const StorageInitial();
}

class StorageLoaded extends StorageState {
  final Map<String, LoadingState> loadingStates;
  final Map<String, Map<String, LivitException>>? exceptions;

  const StorageLoaded({required this.loadingStates, required this.exceptions});
}

