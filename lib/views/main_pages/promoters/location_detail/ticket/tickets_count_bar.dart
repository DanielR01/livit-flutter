part of '../location_detail.dart';

class TicketsCountBar extends StatefulWidget {
  const TicketsCountBar({super.key});

  @override
  State<TicketsCountBar> createState() => _TicketsCountBarState();
}

class _TicketsCountBarState extends State<TicketsCountBar> {
  late final LocationBloc _locationBloc;
  late final TicketBloc _ticketBloc;
  final _debugger = const LivitDebugger('TicketsCountBar');

  List<DateTime> _selectedDateRange = [DateTime.now(), DateTime.now()];

  @override
  void initState() {
    super.initState();
    _locationBloc = BlocProvider.of<LocationBloc>(context);
    _ticketBloc = BlocProvider.of<TicketBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationBloc, LocationState>(
      listener: (context, state) {
        _debugger.debPrint('Fetching tickets count', DebugMessageType.methodCalling);
        _ticketBloc.add(FetchTicketsCountByDate(
          startDate: Timestamp.fromDate(DateTime(_selectedDateRange[0].year, _selectedDateRange[0].month, _selectedDateRange[0].day)),
          endDate: Timestamp.fromDate(DateTime(_selectedDateRange[1].year, _selectedDateRange[1].month, _selectedDateRange[1].day)),
        ));
      },
      child: BlocBuilder<TicketBloc, TicketState>(
        builder: (context, state) {
          _debugger.debPrint('Building', DebugMessageType.building);
          late int? ticketsCount;
          late bool isError;
          if (state is TicketCountLoaded && state.loadingStates[_locationBloc.currentLocation!.id] == LoadingState.loading) {
            ticketsCount = null;
            isError = false;
          } else if (state is TicketCountLoaded && state.loadingStates[_locationBloc.currentLocation!.id] == LoadingState.loaded) {
            ticketsCount = state.ticketCounts[_locationBloc.currentLocation!.id];
            isError = false;
          } else if (state is TicketInitial ||
              (state is TicketCountLoaded && !state.loadingStates.containsKey(_locationBloc.currentLocation!.id))) {
            ticketsCount = null;
            isError = false;
            _ticketBloc.add(FetchTicketsCountByDate(
              startDate: Timestamp.fromDate(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)),
              endDate: Timestamp.fromDate(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1)),
            ));
          } else {
            ticketsCount = null;
            isError = true;
          }
          return LivitBar(
            shadowType: ShadowType.weak,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isError) ...[
                          LivitText('Error al cargar tickets vendidos', color: LivitColors.whiteInactive),
                          LivitSpaces.xs,
                          Icon(
                            CupertinoIcons.exclamationmark_circle,
                            size: LivitButtonStyle.iconSize,
                            color: LivitColors.yellowError,
                          )
                        ] else ...[
                          Icon(
                            CupertinoIcons.tickets,
                            size: LivitButtonStyle.iconSize,
                            color: LivitColors.whiteActive,
                          ),
                          LivitSpaces.xs,
                          LivitText('Tickets vendidos: ', textType: LivitTextType.regular),
                          if (ticketsCount != null) ...[
                            LivitText('$ticketsCount', textType: LivitTextType.regular),
                          ] else
                            CupertinoActivityIndicator(
                              radius: LivitButtonStyle.iconSize / 2,
                              color: LivitColors.whiteActive,
                            ),
                        ],
                      ],
                    ),
                    LivitSpaces.s,
                    Flexible(
                      child: LivitDatePicker(
                        onSelected: (date) {
                          _debugger.debPrint('Date selected: $date', DebugMessageType.info);
                          if (date == null) return;
                          setState(() {
                            _selectedDateRange = date;
                          });
                          if (_selectedDateRange.length == 1) {
                            _ticketBloc.add(FetchTicketsCountByDate(
                              startDate: Timestamp.fromDate(_selectedDateRange[0]),
                              endDate: Timestamp.fromDate(_selectedDateRange[0]),
                            ));
                          } else {
                            _ticketBloc.add(FetchTicketsCountByDate(
                              startDate: Timestamp.fromDate(_selectedDateRange[0]),
                              endDate: Timestamp.fromDate(_selectedDateRange[1]),
                            ));
                          }
                        },
                        defaultDate: DateTime.now(),
                        isActive: true,
                        selectedDateRange: _selectedDateRange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
