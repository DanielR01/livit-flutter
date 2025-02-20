part of 'location_detail.dart';

class LocationDescription extends StatelessWidget {
  final String? description;
  const LocationDescription({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      hasPadding: true,
      // shadowType: ShadowType.none,
      child: Column(
        children: [
          if (description == null)
            LivitBar(
              shadowType: ShadowType.weak,
              child: Center(
                child: LivitText('Descripción', textType: LivitTextType.smallTitle),
              ),
            )
          else
            LivitBar.expandable(
              buttons: [
                Button.secondary(
                  boxShadow: [LivitShadows.inactiveWhiteShadow],
                  text: 'Editar',
                  onTap: () {},
                  isActive: true,
                  rightIcon: CupertinoIcons.pencil_circle,
                ),
              ],
              titleText: 'Descripción',
            ),
          BlocBuilder<LocationBloc, LocationState>(
            builder: (context, state) {
              if (state is LocationsLoaded && state.loadingStates['cloud'] == LoadingState.loaded) {
                return Padding(
                  padding: LivitContainerStyle.padding(),
                  child: Column(
                    children: [
                      LivitText(description ?? 'Describe tu lugar para que tus clientes puedan conocerte mejor y encontrarte fácilmente.',
                          textType: LivitTextType.regular),
                      if (description == null) ...[
                        LivitSpaces.s,
                        Button.main(
                          text: 'Agregar descripción',
                          onTap: () {},
                          isActive: true,
                          rightIcon: CupertinoIcons.add_circled,
                        ),
                      ],
                    ],
                  ),
                );
              }
              return Padding(
                padding: LivitContainerStyle.padding(),
                child: CupertinoActivityIndicator(
                  radius: LivitButtonStyle.iconSize / 2,
                  color: LivitColors.whiteActive,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
