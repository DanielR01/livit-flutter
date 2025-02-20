part of '../location_detail.dart';

class NextEventSnippet extends StatelessWidget {
  final String locationId;

  const NextEventSnippet({super.key, required this.locationId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsBloc, EventsState>(
      builder: (context, state) {
        debugPrint('🛠️ [LocationDetailView] Building next event snippet, state: $state');
        final bool isLoading = state is EventsLoaded && state.loadingStates[locationId] == LoadingState.loading;
        final List<LivitEvent> events = state is EventsLoaded ? state.loadedEvents[EventViewType.location]![locationId] ?? [] : [];
        final LivitEvent? nextEvent = events.isNotEmpty ? events.first : null;
        return GlassContainer(
          hasPadding: true,
          // shadowType: ShadowType.none,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (nextEvent == null)
                LivitBar(
                  shadowType: ShadowType.weak,
                  child: LivitText('Próximo evento', textType: LivitTextType.smallTitle),
                )
              else
                LivitBar.expandable(
                  titleText: 'Próximo evento',
                  buttons: [
                    Button.secondary(
                      boxShadow: [LivitShadows.inactiveWhiteShadow],
                      isActive: true,
                      text: 'Crear nuevo evento',
                      rightIcon: CupertinoIcons.calendar_badge_plus,
                      onTap: () {},
                    ),
                  ],
                ),
              if (isLoading)
                Padding(
                  padding: LivitContainerStyle.padding(),
                  child: PreviewField.eventLoading(isPromoter: true),
                )
              else if (nextEvent != null)
                Padding(
                  padding: LivitContainerStyle.padding(),
                  child: PreviewField.event(nextEvent, isPromoter: true),
                )
              else
                Padding(
                  padding: LivitContainerStyle.padding(),
                  child: Column(
                    children: [
                      LivitText(
                        'No tienes próximos eventos.',
                        textType: LivitTextType.regular,
                      ),
                      LivitSpaces.s,
                      Button.main(
                        isActive: true,
                        text: 'Crea o programa nuevos eventos',
                        onTap: () {},
                        rightIcon: CupertinoIcons.calendar_badge_plus,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
