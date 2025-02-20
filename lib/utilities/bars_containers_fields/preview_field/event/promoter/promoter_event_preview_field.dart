part of '../../preview_field.dart';

class PromoterEventPreviewField extends StatefulWidget {
  final LivitEvent event;
  const PromoterEventPreviewField({super.key, required this.event});

  @override
  State<PromoterEventPreviewField> createState() => _PromoterEventPreviewFieldState();
}

class _PromoterEventPreviewFieldState extends State<PromoterEventPreviewField> {
  late final TicketBloc _ticketBloc;
  int? _ticketsCount;

  @override
  void initState() {
    super.initState();
    _ticketBloc = BlocProvider.of<TicketBloc>(context);
    _ticketBloc.add(FetchTicketsCountByEvent(eventId: widget.event.id));
  }

  @override
  Widget build(BuildContext context) {
    final LivitEvent event = widget.event;
    final LivitMediaFile? mediaFile = event.media.media.first;
    return LivitBar(
      noPadding: true,
      shadowType: ShadowType.weak,
      child: Padding(
        padding: LivitContainerStyle.padding(),
        child: Row(
          // crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (mediaFile is LivitMediaImage)
              SmallImageContainer.fromImageUrl(mediaFile.url)
            else if (mediaFile is LivitMediaVideo)
              SmallImageContainer.fromImageUrl(mediaFile.cover.url)
            else
              SmallImageContainer.noImage(),
            LivitSpaces.m,
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  LivitText(event.name, textType: LivitTextType.smallTitle),
                  LivitSpaces.m,
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.calendar,
                        color: LivitColors.mainBlueActive,
                        size: LivitButtonStyle.iconSize,
                      ),
                      LivitSpaces.xs,
                      LivitText(
                        formatDate(event.startTime.toDate()),
                        textType: LivitTextType.regular,
                        color: LivitColors.mainBlueActive,
                      ),
                    ],
                  ),
                  LivitSpaces.xs,
                  BlocBuilder<TicketBloc, TicketState>(
                    builder: (context, state) {
                      if (state is TicketCountLoaded && state.loadingStates[event.id] == LoadingState.loaded) {
                        _ticketsCount = state.ticketCounts[event.id];
                      } else {
                        _ticketsCount = null;
                      }
                      if (_ticketsCount == null) {
                        return Row(
                          children: [
                            CupertinoActivityIndicator(
                              color: LivitColors.whiteActive,
                              radius: LivitButtonStyle.iconSize / 2,
                            ),
                            LivitSpaces.xs,
                            LivitText('Cargando ventas', textType: LivitTextType.regular),
                          ],
                        );
                      }
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.tickets,
                            color: LivitColors.whiteActive,
                            size: LivitButtonStyle.iconSize,
                          ),
                          LivitSpaces.xs,
                          LivitText(
                            _ticketsCount.toString(),
                            textType: LivitTextType.regular,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} ${date.hour > 12 ? date.hour - 12 : date.hour}:${date.minute.toString().padLeft(2, '0')} ${date.hour > 12 ? 'PM' : 'AM'}";
  }
}
