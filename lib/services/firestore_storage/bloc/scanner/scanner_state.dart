part of 'scanner_bloc.dart';

abstract class ScannerState {
  final Map<String, LoadingState> loadingStates;

  ScannerState({required this.loadingStates});
}

class ScannerInitial extends ScannerState {
  ScannerInitial() : super(loadingStates: {});
}

class ScannerLoading extends ScannerState {
  ScannerLoading({required super.loadingStates});
}

class ScannerSuccess extends ScannerState {
  final List<CloudScanner> scanners;
  final CloudScanner? createdScanner;

  ScannerSuccess({
    required this.scanners,
    this.createdScanner,
    required super.loadingStates,
  });
}

class ScannerError extends ScannerState {
  final String error;

  ScannerError({
    required this.error,
    required super.loadingStates,
  });
}
