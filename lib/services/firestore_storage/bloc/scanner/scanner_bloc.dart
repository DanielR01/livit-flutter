import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/models/user/cloud_user.dart';
import 'package:livit/services/cloud_functions/firestore_cloud_functions.dart';
import 'package:livit/services/error_reporting/error_reporter.dart';
import 'package:livit/services/firestore_storage/bloc/user/user_bloc.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/services/firestore_storage/firestore_storage/firestore_storage.dart';

part 'scanner_event.dart';
part 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final FirestoreCloudFunctions _cloudFunctions;
  final ErrorReporter _errorReporter;
  final UserBloc _userBloc;
  final Map<String, LoadingState> loadingStates = {};
  final FirestoreStorageService _firestoreStorageService;

  List<CloudScanner> scanners = [];

  ScannerBloc({
    required FirestoreCloudFunctions cloudFunctions,
    required ErrorReporter errorReporter,
    required UserBloc userBloc,
    required FirestoreStorageService firestoreStorageService,
  })  : _cloudFunctions = cloudFunctions,
        _errorReporter = errorReporter,
        _userBloc = userBloc,
        _firestoreStorageService = firestoreStorageService,
        super(ScannerInitial()) {
    on<CreateScanner>(_onCreateScanner);
    on<UpdateScannerAccess>(_onUpdateScannerAccess);
    on<GetScannersByLocationId>(_onGetScannersByLocationId);
  }

  void _ensureUserIsPromoter() {
    if (_userBloc.currentUser is! CloudPromoter) {
      throw Exception('User is not a promoter');
    }
  }

  Future<void> _onCreateScanner(
    CreateScanner event,
    Emitter<ScannerState> emit,
  ) async {
    try {
      loadingStates[event.locationId] = LoadingState.creating;
      emit(ScannerLoading(loadingStates: loadingStates));
      _ensureUserIsPromoter();

      final String scannerId = await _cloudFunctions.createScannerAccount(
        promoterId: _userBloc.currentUser!.id,
        locationIds: [event.locationId],
        eventIds: event.eventId != null ? [event.eventId!] : [],
        name: event.name.trim(),
      );

      final scanner = await _firestoreStorageService.scannerService.getScannerById(scannerId);
      scanners.add(scanner);
      loadingStates[event.locationId] = LoadingState.created;
      emit(ScannerSuccess(
        scanners: scanners,
        createdScanner: scanner,
        loadingStates: loadingStates,
      ));
    } catch (e, stackTrace) {
      _errorReporter.reportError(e, stackTrace);
      loadingStates[event.locationId] = LoadingState.error;
      emit(ScannerError(
        error: e.toString(),
        loadingStates: loadingStates,
      ));
    }
  }

  Future<void> _onUpdateScannerAccess(
    UpdateScannerAccess event,
    Emitter<ScannerState> emit,
  ) async {
    // Similar implementation to _onCreateScanner
  }

  Future<void> _onGetScannersByLocationId(
    GetScannersByLocationId event,
    Emitter<ScannerState> emit,
  ) async {
    try {
      debugPrint('📥 [ScannerBloc] Getting scanners by location id: ${event.locationId}');
      _ensureUserIsPromoter();
      loadingStates[event.locationId] = LoadingState.loading;
      emit(ScannerLoading(loadingStates: loadingStates));
      scanners = await _firestoreStorageService.scannerService.getScannersByLocationId(locationId: event.locationId);
      debugPrint('📥 [ScannerBloc] Found ${scanners.length} scanners');
      loadingStates[event.locationId] = LoadingState.loaded;
      emit(ScannerSuccess(
        loadingStates: loadingStates,
        scanners: scanners,
      ));
    } catch (e) {
      debugPrint('❌ [ScannerBloc] Error getting scanners by location id: ${event.locationId}');
      loadingStates[event.locationId] = LoadingState.error;
      _errorReporter.reportError(e, StackTrace.current);
      emit(ScannerError(
        error: e.toString(),
        loadingStates: loadingStates,
      ));
    }
  }
}
