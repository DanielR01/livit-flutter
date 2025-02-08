import 'package:flutter/cupertino.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/models/event/event.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/bars_containers_fields/small_image_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/ticket/ticket_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/ticket/ticket_state.dart';
import 'package:livit/services/firestore_storage/bloc/ticket/ticket_event.dart';
import 'package:shimmer/shimmer.dart';

class EventPreview extends StatefulWidget {
  final LivitEvent? event;
  final EventPreviewType type;
  final EventPreviewLayout layoutType;

  const EventPreview({
    super.key,
    required this.event,
    this.type = EventPreviewType.customer,
    this.layoutType = EventPreviewLayout.horizontal,
  });

  factory EventPreview.loading({
    EventPreviewType type = EventPreviewType.customer,
    EventPreviewLayout layoutType = EventPreviewLayout.horizontal,
  }) =>
      EventPreview(
        event: null,
        type: type,
        layoutType: layoutType,
      );

  factory EventPreview.promoter({
    LivitEvent? event,
    EventPreviewLayout layoutType = EventPreviewLayout.horizontal,
  }) =>
      EventPreview(
        event: event,
        type: EventPreviewType.promoter,
        layoutType: layoutType,
      );

  factory EventPreview.customer({
    LivitEvent? event,
    EventPreviewLayout layoutType = EventPreviewLayout.vertical,
  }) =>
      EventPreview(
        event: event,
        type: EventPreviewType.customer,
        layoutType: layoutType,
      );

  @override
  State<EventPreview> createState() => _EventPreviewState();
}

class _EventPreviewState extends State<EventPreview> {
  late TicketBloc _ticketBloc;

  @override
  void initState() {
    super.initState();
    _ticketBloc = context.read<TicketBloc>();
    if (widget.type == EventPreviewType.promoter && widget.event != null) {
      _ticketBloc.add(FetchTicketsCountByEvent(eventId: widget.event!.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: widget.event == null
          ? Shimmer.fromColors(
              baseColor: LivitColors.whiteInactive.withOpacity(1),
              highlightColor: LivitColors.whiteActive.withOpacity(1),
              child: Row(
                children: _buildContent(widget.event == null),
              ),
            )
          : Row(
              children: _buildContent(widget.event == null),
            ),
    );
  }

  List<Widget> _buildContent(bool isLoading) {
    return [
      SmallImageContainer(filePath: null),
      Padding(
        padding: EdgeInsets.all(LivitContainerStyle.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLoading)
              Container(
                decoration: BoxDecoration(
                  color: LivitColors.whiteActive,
                  borderRadius: LivitContainerStyle.borderRadius,
                ),
                height: LivitTextStyle.smallTitleFontSize,
                width: LivitSpaces.xlDouble * 5,
              )
            else
              LivitText(
                widget.event!.name,
                textType: LivitTextType.smallTitle,
              ),
            LivitSpaces.s,
            Row(
              children: [
                Icon(CupertinoIcons.calendar, color: LivitColors.mainBlueActive, size: LivitButtonStyle.iconSize),
                LivitSpaces.xs,
                if (isLoading)
                  Container(
                    decoration: BoxDecoration(
                      color: LivitColors.mainBlueActive,
                      borderRadius: LivitContainerStyle.borderRadius,
                    ),
                    height: LivitTextStyle.regularFontSize,
                    width: LivitSpaces.xlDouble * 4,
                  )
                else
                  LivitText(widget.event!.toDateString(), color: LivitColors.mainBlueActive),
              ],
            ),
            if (widget.type == EventPreviewType.promoter) ...[
              LivitSpaces.m,
              BlocBuilder<TicketBloc, TicketState>(
                builder: (context, state) {
                  debugPrint('🛠️ [EventPreview] State: $state');
                  if (state is TicketCountLoaded) {
                    debugPrint('🛠️ [EventPreview] LoadingStates: ${state.loadingStates}');
                    if (state.loadingStates[widget.event?.id] == LoadingState.loaded) {
                      return Row(
                        children: [
                          Icon(CupertinoIcons.tickets, color: LivitColors.whiteActive, size: LivitButtonStyle.iconSize),
                          LivitSpaces.xs,
                          LivitText('Tickets vendidos: ${state.ticketCounts[widget.event!.id]}'),
                        ],
                      );
                    } else if (state.loadingStates[widget.event?.id] == LoadingState.loading || widget.event == null) {
                      return Row(
                        children: [
                          Icon(CupertinoIcons.tickets, color: LivitColors.whiteActive, size: LivitButtonStyle.iconSize),
                          LivitSpaces.xs,
                          Container(
                            decoration: BoxDecoration(
                              color: LivitColors.whiteActive,
                              borderRadius: LivitContainerStyle.borderRadius,
                            ),
                            height: LivitTextStyle.regularFontSize,
                            width: LivitSpaces.xlDouble * 3,
                          ),
                        ],
                      );
                    } else if (!state.loadingStates.containsKey(widget.event?.id)) {
                      _ticketBloc.add(FetchTicketsCountByEvent(eventId: widget.event!.id));
                      return Row(
                        children: [
                          Icon(CupertinoIcons.tickets, color: LivitColors.whiteActive, size: LivitButtonStyle.iconSize),
                          LivitSpaces.xs,
                          Container(
                            decoration: BoxDecoration(
                              color: LivitColors.whiteActive,
                              borderRadius: LivitContainerStyle.borderRadius,
                            ),
                            height: LivitTextStyle.regularFontSize,
                            width: LivitSpaces.xlDouble * 3,
                          ),
                        ],
                      );
                    } else {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const LivitText('Error al cargar tickets', color: LivitColors.whiteInactive),
                          LivitSpaces.xs,
                          Icon(
                            CupertinoIcons.exclamationmark_circle,
                            size: LivitButtonStyle.iconSize,
                            color: LivitColors.whiteInactive,
                          ),
                        ],
                      );
                    }
                  } else {
                    if (widget.event != null) {
                      _ticketBloc.add(FetchTicketsCountByEvent(eventId: widget.event!.id));
                    }
                    return Container(
                      decoration: BoxDecoration(
                        color: LivitColors.whiteActive,
                        borderRadius: LivitContainerStyle.borderRadius,
                      ),
                      height: LivitTextStyle.regularFontSize,
                      width: LivitSpaces.xlDouble * 3,
                    );
                  }
                },
              ),
            ],
          ],
        ),
      ),
    ];
  }
}

enum EventPreviewType { promoter, customer }

enum EventPreviewLayout { horizontal, vertical }
