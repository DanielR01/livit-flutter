// lib/bloc/ticket/ticket_bloc.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/models/user/cloud_user.dart';
import 'package:livit/services/background/background_bloc.dart';
import 'package:livit/services/background/background_events.dart';
import 'package:livit/services/error_reporting/error_reporter.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/ticket/ticket_bloc_exception.dart';
import 'package:livit/services/firestore_storage/bloc/ticket/ticket_event.dart';
import 'package:livit/services/firestore_storage/bloc/ticket/ticket_state.dart';
import 'package:livit/services/firestore_storage/bloc/user/user_bloc.dart';
import 'package:livit/services/firestore_storage/firestore_storage/firestore_storage.dart';

class TicketBloc extends Bloc<TicketEvent, TicketState> {
  final FirestoreStorageService _firestoreStorage;
  final LocationBloc _locationBloc;
  final BackgroundBloc _backgroundBloc;
  final UserBloc _userBloc;
  final ErrorReporter _errorReporter;

  Map<String, LoadingState> loadingStates = {};
  Map<String, int> ticketCounts = {};
  Map<String, String> errorMessages = {};

  List<Timestamp>? _selectedDateRange;
  TicketBloc(
      {required FirestoreStorageService firestoreStorage,
      required LocationBloc locationBloc,
      required BackgroundBloc backgroundBloc,
      required UserBloc userBloc})
      : _firestoreStorage = firestoreStorage,
        _locationBloc = locationBloc,
        _backgroundBloc = backgroundBloc,
        _userBloc = userBloc,
        _errorReporter = ErrorReporter(),
        super(TicketInitial()) {
    on<FetchTicketsCountByDate>(_onFetchTicketsCountByDate);
    on<FetchTicketsCountByEvent>(_onFetchTicketsCountByEvent);
    on<RefreshTicketsCountByDate>(_onRefreshTicketsCountByDate);
  }

  Future<void> _onFetchTicketsCountByDate(
    FetchTicketsCountByDate event,
    Emitter<TicketState> emit,
  ) async {
    debugPrint('🛠️ [TicketBloc] Fetching tickets count for ${event.startDate} to ${event.endDate}');
    try {
      _ensureLocationIsSet();
      _ensureUserIsPromoter();
      _selectedDateRange = [event.startDate, event.endDate];
      loadingStates[_locationBloc.currentLocation!.id] = LoadingState.loading;
      emit(TicketCountLoaded(
        loadingStates: loadingStates,
        ticketCounts: ticketCounts,
      ));
      final count = await _firestoreStorage.ticketService.getTicketsSoldInDateRange(
        promoterId: _userBloc.currentUser!.id,
        startDate: event.startDate,
        endDate: event.endDate,
        locationId: _locationBloc.currentLocation!.id,
      );
      debugPrint('🛠️ [TicketBloc] Tickets count for ${event.startDate} to ${event.endDate}: $count');
      ticketCounts[_locationBloc.currentLocation!.id] = count;
      loadingStates[_locationBloc.currentLocation!.id] = LoadingState.loaded;
      emit(TicketCountLoaded(
        loadingStates: loadingStates,
        ticketCounts: ticketCounts,
      ));
    } catch (e) {
      debugPrint('🛠️ [TicketBloc] Error fetching tickets count: ${e.toString()}');
      loadingStates[_locationBloc.currentLocation!.id] = LoadingState.error;
      errorMessages[_locationBloc.currentLocation!.id] = e.toString();
      emit(TicketCountLoaded(
        loadingStates: loadingStates,
        ticketCounts: ticketCounts,
        errorMessages: errorMessages,
      ));
      _errorReporter.reportError(e, StackTrace.current);
    } finally {
      _backgroundBloc.add(BackgroundStopLoadingAnimation());
    }
  }

  Future<void> _onRefreshTicketsCountByDate(
    RefreshTicketsCountByDate event,
    Emitter<TicketState> emit,
  ) async {
    if (_selectedDateRange?.isNotEmpty == true) {
      add(FetchTicketsCountByDate(startDate: _selectedDateRange![0], endDate: _selectedDateRange![1]));
    } else {
      add(FetchTicketsCountByDate(
        startDate: Timestamp.fromDate(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)),
        endDate: Timestamp.fromDate(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1)),
      ));
    }
  }

  Future<void> _onFetchTicketsCountByEvent(
    FetchTicketsCountByEvent event,
    Emitter<TicketState> emit,
  ) async {
    try {
      _ensureLocationIsSet();
      _ensureUserIsPromoter();
      loadingStates[event.eventId] = LoadingState.loading;
      debugPrint('🛠️ [TicketBloc] Fetching tickets count for event: ${event.eventId}');
      emit(TicketCountLoaded(
        loadingStates: loadingStates,
        ticketCounts: ticketCounts,
      ));
      final count = await _firestoreStorage.ticketService.getTicketsSoldForEvent(
        eventId: event.eventId,
        promoterId: _userBloc.currentUser!.id,
      );
      debugPrint('🛠️ [TicketBloc] Tickets count for ${event.eventId}: $count');
      ticketCounts[event.eventId] = count;
      loadingStates[event.eventId] = LoadingState.loaded;
      emit(TicketCountLoaded(
        loadingStates: loadingStates,
        ticketCounts: ticketCounts,
      ));
    } catch (e) {
      debugPrint('❌ [TicketBloc] Error fetching event tickets count: $e');
      loadingStates[event.eventId] = LoadingState.error;
      errorMessages[event.eventId] = e.toString();
      emit(TicketCountLoaded(
        loadingStates: loadingStates,
        ticketCounts: ticketCounts,
        errorMessages: errorMessages,
      ));
    }
  }

  _ensureLocationIsSet() {
    if (_locationBloc.currentLocation?.id == null) {
      debugPrint('🛠️ [TicketBloc] No location set');
      throw TicketBlocNoLocationException();
    }
  }

  _ensureUserIsPromoter() {
    if (_userBloc.currentUser is! CloudPromoter) {
      debugPrint('🛠️ [TicketBloc] User is not a promoter');
      throw TicketBlocUserNotPromoterException();
    }
  }
}
