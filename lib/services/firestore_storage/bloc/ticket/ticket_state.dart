import 'package:livit/constants/enums.dart';

abstract class TicketState {}

class TicketInitial extends TicketState {}

class TicketCountLoaded extends TicketState {
  final Map<String, LoadingState> loadingStates;
  final Map<String, int> ticketCounts;
  final Map<String, String>? errorMessages;

  TicketCountLoaded({required this.loadingStates, required this.ticketCounts, this.errorMessages});
}

