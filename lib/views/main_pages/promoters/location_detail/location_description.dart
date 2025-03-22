part of 'location_detail.dart';

class LocationDescription extends StatefulWidget {
  const LocationDescription({super.key});

  @override
  State<LocationDescription> createState() => _LocationDescriptionState();
}

class _LocationDescriptionState extends State<LocationDescription> {
  late final LocationBloc _locationBloc;
  late final TextEditingController _descriptionController;
  bool isEditing = false;
  bool isSaving = false;

  bool _isDescriptionValid = false;

  @override
  void initState() {
    super.initState();
    _locationBloc = context.read<LocationBloc>();
    _descriptionController = TextEditingController();
    _descriptionController.addListener(_listenToDescriptionChanges);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _listenToDescriptionChanges() {
    setState(() {
      _isDescriptionValid = _descriptionController.text.length <= 100;
    });
  }

  void _handleEditDescription(BuildContext context) {
    final currentDescription = _locationBloc.currentLocation?.description ?? '';
    _descriptionController.text = currentDescription;
    setState(() {
      isEditing = true;
    });
  }

  void _saveDescription(BuildContext context) {
    setState(() {
      isSaving = true;
    });

    final currentLocation = _locationBloc.currentLocation;
    if (currentLocation != null) {
      if (_descriptionController.text == currentLocation.description) {
        setState(() {
          isEditing = false;
          isSaving = false;
        });
        return;
      }
      final updatedLocation = currentLocation.copyWith(
        description: _descriptionController.text,
      );

      _locationBloc.add(UpdateLocationToCloud(
        context,
        location: updatedLocation,
      ));

      // Exit editing mode
      setState(() {
        isEditing = false;
        isSaving = false;
      });
    }
  }

  Widget _buildBottomCaptionCharCount() {
    int charCount = _descriptionController.text.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LivitSpaces.s,
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            LivitText('$charCount/100 caracteres', textType: LivitTextType.regular, color: LivitColors.whiteInactive),
          ],
        ),
      ],
    );
  }

  Widget _buildEditDescription() {
    return Column(
      children: [
        LivitTextField(
          controller: _descriptionController,
          hint: 'Describe tu lugar para que tus clientes puedan conocerte mejor y encontrarte fácilmente.',
          isMultiline: true,
          bottomCaptionWidget: _buildBottomCaptionCharCount(),
          disableCheckValidity: true,
        ),
        LivitSpaces.s,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Button.secondary(
              text: 'Cancelar',
              isActive: !isSaving,
              onTap: () {
                setState(() {
                  isEditing = false;
                });
              },
              rightIcon: CupertinoIcons.xmark_circle,
            ),
            Button.main(
              text: isSaving ? 'Guardando' : 'Guardar',
              isActive: !isSaving && _isDescriptionValid,
              isLoading: isSaving,
              onTap: () => _saveDescription(context),
              rightIcon: CupertinoIcons.checkmark_alt_circle,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBar(LocationState state) {
    if (state is LocationsLoaded && state.loadingStates['cloud'] == LoadingState.loaded) {
      final String? description = _locationBloc.currentLocation?.description;
      if (description == null || description == '' || isEditing) {
        return LivitBar(
          shadowType: ShadowType.weak,
          child: Center(
            child: LivitText('Descripción', textType: LivitTextType.smallTitle),
          ),
        );
      } else {
        return LivitBar.expandable(
          buttons: [
            Button.secondary(
              boxShadow: [LivitShadows.inactiveWhiteShadow],
              text: 'Editar',
              onTap: () => _handleEditDescription(context),
              isActive: true,
              rightIcon: CupertinoIcons.pencil_circle,
            ),
          ],
          titleText: 'Descripción',
        );
      }
    } else {
      return LivitBar(
        shadowType: ShadowType.weak,
        child: Center(
          child: LivitText('Descripción', textType: LivitTextType.smallTitle),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      hasPadding: true,
      child: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, state) {
          late final Widget content;
          if (state is LocationsLoaded && state.loadingStates['cloud'] == LoadingState.loaded) {
            final String? description = _locationBloc.currentLocation?.description;
            content = Padding(
              padding: LivitContainerStyle.padding(),
              child: isEditing
                  ? _buildEditDescription()
                  : Column(
                      children: [
                        LivitText(
                          (description == null || description == '')
                              ? 'Describe tu lugar para que tus clientes puedan conocerte mejor y encontrarte fácilmente.'
                              : description,
                          textType: LivitTextType.regular,
                        ),
                        if (description == null || description == '') ...[
                          LivitSpaces.s,
                          Button.main(
                            text: 'Agregar descripción',
                            onTap: () => _handleEditDescription(context),
                            isActive: true,
                            rightIcon: CupertinoIcons.add_circled,
                          ),
                        ],
                      ],
                    ),
            );
          } else if (state is LocationsLoaded && state.loadingStates['cloud'] == LoadingState.loading) {
            content = Padding(
              padding: LivitContainerStyle.padding(),
              child: CupertinoActivityIndicator(
                radius: LivitButtonStyle.iconSize / 2,
                color: LivitColors.whiteActive,
              ),
            );
          } else {
            content = Padding(
              padding: LivitContainerStyle.padding(),
              child: Row(
                children: [
                  LivitText('Error al cargar la descripción', textType: LivitTextType.regular),
                  LivitSpaces.xs,
                  Icon(
                    CupertinoIcons.exclamationmark_circle,
                    color: LivitColors.yellowError,
                    size: LivitButtonStyle.iconSize,
                  ),
                ],
              ),
            );
          }
          return Column(
            children: [
              _buildBar(state),
              content,
            ],
          );
        },
      ),
    );
  }
}
