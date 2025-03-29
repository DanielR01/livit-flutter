part of '../location_detail.dart';

class LocationMediaPreview extends StatefulWidget {
  const LocationMediaPreview({super.key});

  @override
  State<LocationMediaPreview> createState() => _LocationMediaPreviewState();
}

class _LocationMediaPreviewState extends State<LocationMediaPreview> {
  late LocationBloc _locationBloc;
  @override
  void initState() {
    super.initState();
    _locationBloc = BlocProvider.of<LocationBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final remainingWidth = screenWidth -
        LivitContainerStyle.paddingFromScreen.horizontal -
        LivitContainerStyle.horizontalPadding * 2 -
        LivitSpaces.sDouble * 3;
    final mediaDisplayWidth = remainingWidth / 4;
    final mediaDisplayHeight = mediaDisplayWidth * 16 / 9;

    // Get parent's debugger instance
    final _debugger = (context.findAncestorStateOfType<_LocationDetailViewState>())?._debugger ?? const LivitDebugger('LocationDetailView');

    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        final hasMedia = _locationBloc.currentLocation?.media?.files?.isNotEmpty ?? false;
        return GlassContainer(
          hasPadding: true,
          // shadowType: ShadowType.none,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasMedia)
                LivitBar.expandable(
                  buttons: [
                    Button.secondary(
                      boxShadow: [LivitShadows.inactiveWhiteShadow],
                      rightIcon: CupertinoIcons.eye_fill,
                      text: 'Ver como cliente',
                      onTap: () {},
                      isActive: true,
                    ),
                    Button.secondary(
                      boxShadow: [LivitShadows.inactiveWhiteShadow],
                      rightIcon: CupertinoIcons.pencil_circle,
                      text: 'Editar',
                      onTap: () {},
                      isActive: true,
                    ),
                  ],
                  titleText: 'Media',
                )
              else
                LivitBar(
                  shadowType: ShadowType.weak,
                  child: Center(
                    child: LivitText('Media', textType: LivitTextType.smallTitle),
                  ),
                ),
              if (state is LocationsLoaded && state.loadingStates[_locationBloc.currentLocation?.id] == LoadingState.loading)
                _buildLoadingState()
              else if (!hasMedia)
                _buildEmptyState()
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: LivitContainerStyle.padding(),
                    child: Row(
                      children: [
                        ..._locationBloc.currentLocation!.media!.files!.map(
                          (file) => GestureDetector(
                            onTap: () => _showMediaPreviewDialog(file),
                            child: Container(
                              width: mediaDisplayWidth,
                              height: mediaDisplayHeight,
                              decoration: LivitContainerStyle.decorationWithInactiveShadow,
                              clipBehavior: Clip.hardEdge,
                              child: _buildMediaPreview(file!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: LivitContainerStyle.padding(),
      child: CupertinoActivityIndicator(
        radius: LivitButtonStyle.iconSize / 2,
        color: LivitColors.whiteActive,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: LivitContainerStyle.padding(),
      child: Column(
        children: [
          LivitText(
            'No tienes ninguna imagen o video para mostrar.',
            textType: LivitTextType.regular,
          ),
          LivitSpaces.s,
          Button.main(
            isActive: true,
            text: 'Añade una imagen o video',
            onTap: () {},
            rightIcon: CupertinoIcons.photo_fill_on_rectangle_fill,
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPreview(LivitMediaFile file) {
    final _debugger = const LivitDebugger('LocationDetailView');

    if (file is LivitMediaImage) {
      _debugger.debPrint('Building media preview for image: ${file.url}', DebugMessageType.building);
      return Image.network(
        (file.url ?? ''),
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CupertinoActivityIndicator(
              radius: LivitButtonStyle.iconSize / 2,
              color: LivitColors.whiteActive,
            ),
          );
        },
      );
    } else if (file is LivitMediaVideo) {
      _debugger.debPrint(
          'Building media preview for video with cover: ${file.cover.url} and video: ${file.url}', DebugMessageType.building);
      return Stack(
        alignment: Alignment.center,
        children: [
          Image.network(
            file.cover.url ?? '',
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CupertinoActivityIndicator(
                  radius: LivitButtonStyle.iconSize / 2,
                  color: LivitColors.whiteActive,
                ),
              );
            },
          ),
          Icon(
            CupertinoIcons.play_circle_fill,
            color: LivitColors.whiteActive,
            size: LivitButtonStyle.bigIconSize,
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  void _showMediaPreviewDialog(LivitMediaFile file) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: LivitContainerStyle.decorationWithInactiveShadow,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (file is LivitMediaImage)
                Image.network(
                  file.url ?? '',
                  fit: BoxFit.contain,
                )
              else if (file is LivitMediaVideo)
                // Implement video player here
                Container(),
            ],
          ),
        ),
      ),
    );
  }
}
