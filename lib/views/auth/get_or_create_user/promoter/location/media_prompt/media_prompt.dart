import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/models/location/location.dart';
import 'package:livit/models/location/location_media.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/services/exceptions/base_exception.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_event.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_state.dart';
import 'package:livit/services/firestore_storage/firestore_storage/exceptions/firestore_exceptions.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/display/livit_display_area.dart';
import 'package:livit/utilities/livit_scrollbar.dart';
import 'package:livit/views/auth/get_or_create_user/promoter/location/media_prompt/location_media_prompt_field.dart';

class MediaPrompt extends StatefulWidget {
  const MediaPrompt({super.key});

  @override
  State<MediaPrompt> createState() => _MediaPromptState();
}

class _MediaPromptState extends State<MediaPrompt> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _locationBloc = BlocProvider.of<LocationBloc>(context);
    _locations = _locationBloc.locations;
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  List<LivitLocation> _locations = [];
  late final LocationBloc _locationBloc;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        _locations = _locationBloc.locations;
        try {
          String? continueButtonText;
          if (state is LocationsLoaded) {
            final isValid = _locationBloc.areAllLocationsValid;
            final isCloudLoading = state.loadingStates['cloud'] == LoadingState.loading;
            late final String? errorMessage;
            if (state.errorMessage != null) {
              errorMessage = state.errorMessage;
            } else {
              if (state.failedLocations?.isNotEmpty == true) {
                if (state.failedLocations!.length == 1) {
                  errorMessage = 'No se pudo subir el video o imagen de una de tus locaciones';
                } else {
                  errorMessage = 'No se pudo subir el video o imagen de algunas de tus locaciones';
                }
              } else {
                errorMessage = null;
              }
            }
            int verifyingLocations = 0;
            int uploadingLocations = 0;
            int uploadedLocations = 0;
            int errorLocations = 0;

            int deletingLocations = 0;
            debugPrint('🔄 [LocationBloc] Loading states: ${state.loadingStates}');
            for (final location in state.loadingStates.entries) {
              if (location.key == 'cloud') continue;
              if (location.value == LoadingState.uploading) {
                uploadingLocations++;
              } else if (location.value == LoadingState.verifying) {
                verifyingLocations++;
              } else if (location.value == LoadingState.uploaded) {
                uploadedLocations++;
              } else if (location.value == LoadingState.error) {
                errorLocations++;
              } else if (location.value == LoadingState.loading) {
              } else if (location.value == LoadingState.deleting) {
                deletingLocations++;
              }
            }
            if (verifyingLocations != 0) {
              continueButtonText = 'Verificando ${uploadedLocations + errorLocations + 1} de ${_locations.length}';
            } else if (uploadingLocations != 0 || deletingLocations != 0) {
              continueButtonText = 'Subiendo ${uploadedLocations + errorLocations + 1} de ${_locations.length}';
            } else if (uploadedLocations == _locations.length && isCloudLoading) {
              continueButtonText = 'Completando';
            }

            return Scaffold(
              body: LivitDisplayArea(
                child: Center(
                  child: GlassContainer(
                    hasPadding: false,
                    titleBarText: _locations.length > 1 ? 'Agrega multimedia de tus locaciones' : 'Agrega multimedia de tu locación',
                    child: Flexible(
                      child: Padding(
                        padding: LivitContainerStyle.padding(padding: [0, 0, null, 0]),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: LivitContainerStyle.padding(padding: [0, null, 0, null]),
                              child: LivitText(
                                'Agrega videos o imagenes de tus locaciones para que tus clientes puedan verlos. La imagen o video principal sera la que se muestre como portada de tu locación.',
                              ),
                            ),
                            Flexible(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: LivitContainerStyle.verticalPadding / 2),
                                child: LivitScrollbar(
                                  thumbVisibility: true,
                                  controller: _scrollController,
                                  child: _locationsScroller(
                                    scrollController: _scrollController,
                                    failedLocations: state.failedLocations,
                                  ),
                                ),
                              ),
                            ),
                            if (errorMessage != null) ...[
                              Padding(
                                padding: LivitContainerStyle.padding(padding: [0, null, 0, null]),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    LivitText(
                                      'Revisa que errores han ocurrido',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ],
                                ),
                              ),
                              LivitSpaces.s,
                            ],
                            Padding(
                              padding: EdgeInsets.only(right: LivitContainerStyle.horizontalPadding),
                              child: Row(
                                mainAxisAlignment: continueButtonText == null
                                    ? state.loadingStates['cloud'] == LoadingState.skipping
                                        ? MainAxisAlignment.start
                                        : MainAxisAlignment.spaceBetween
                                    : MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  if (continueButtonText == null)
                                    Button.grayText(
                                      deactivateSplash: true,
                                      isActive: state.loadingStates['cloud'] != LoadingState.loading,
                                      text: state.loadingStates['cloud'] == LoadingState.skipping ? 'Completando' : 'Completar más tarde',
                                      isLoading: state.loadingStates['cloud'] == LoadingState.skipping,
                                      rightIcon: Icons.arrow_forward_ios,
                                      onTap: () {
                                        _locations = _locations.map((location) => location.copyWith(media: LivitLocationMedia())).toList();
                                        BlocProvider.of<LocationBloc>(context).add(SkipUpdateLocationsMediaToCloud(context));
                                      },
                                    ),
                                  if (state.loadingStates['cloud'] != LoadingState.skipping)
                                    Button.main(
                                      isActive: isValid && state.loadingStates['cloud'] != LoadingState.skipping,
                                      text: continueButtonText ?? 'Continuar',
                                      isLoading: isCloudLoading,
                                      onTap: () {
                                        BlocProvider.of<LocationBloc>(context).add(UpdateLocationsMediaToCloudFromLocal(context));
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            throw GenericFirestoreException(details: 'State (${state.runtimeType}) is not a LocationsLoaded');
          }
        } catch (e) {
          throw GenericFirestoreException(details: 'Unknown error in MediaPrompt: $e');
        }
      },
    );
  }

  Widget _locationsScroller(
      {required ScrollController scrollController, required Map<LivitLocation, Map<String, LivitException>>? failedLocations}) {
    return ListView.builder(
      controller: scrollController,
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _locations.length,
      itemBuilder: (context, index) {
        final location = _locations.elementAt(index);
        return Padding(
            padding: LivitContainerStyle.padding(padding: [index != 0 ? 0 : null, null, null, null]),
            child: LocationMediaInputField(location: location, errors: failedLocations?[location]));
      },
    );
  }
}
