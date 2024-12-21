import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/cloud_models/location/location.dart';
import 'package:livit/cloud_models/location/location_media.dart';
import 'package:livit/cloud_models/location/location_media_file.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/services/firestore_storage/bloc/locations/location_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/locations/location_event.dart';
import 'package:livit/services/firestore_storage/bloc/locations/location_state.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/error_screens/error_reauth_screen.dart';
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
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  List<Location> _locations = [];
  bool _isInitialized = false;

  void _initializeLocations(List<Location> locations) {
    _isInitialized = true;
    _locations = locations;
  }

  void _onMainSelected(LivitLocationMediaFile file, Location location) {
    final index = _locations.indexWhere((element) => element.id == location.id);
    if (index != -1) {
      final locationToUpdate = _locations[index];
      final updatedLocation =
          locationToUpdate.copyWith(media: locationToUpdate.media?.copyWith(mainFile: file) ?? LivitLocationMedia(mainFile: file));
      setState(() {
        _locations[index] = updatedLocation;
      });
    }
  }

  void _onSecondarySelected(LivitLocationMediaFile file, Location location) {
    final index = _locations.indexWhere((element) => element.id == location.id);
    if (index != -1) {
      final locationToUpdate = _locations[index];
      final updatedLocation = locationToUpdate.copyWith(
          media: locationToUpdate.media?.copyWith(secondaryFiles: [...(locationToUpdate.media?.secondaryFiles ?? []), file]) ??
              LivitLocationMedia(secondaryFiles: [file]));
      setState(() {
        _locations[index] = updatedLocation;
      });
    }
  }

  void _onMediaReset(Location location) {
    final index = _locations.indexWhere((element) => element.id == location.id);
    if (index != -1) {
      setState(() {
        _locations[index] = location.copyWith(media: null);
      });
    }
  }

  void _onMediaChanged(LivitLocationMedia media, Location location) {
    final index = _locations.indexWhere((element) => element.id == location.id);
    if (index != -1) {
      setState(() {
        _locations[index] = location.copyWith(media: media);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        try {
          if (state is LocationsLoaded) {
            if (!_isInitialized) {
              _initializeLocations(state.locations);
            }
            List<Location?> locations = state.locations;
            final isValid = _locations.every((location) => location.media?.mainFile?.file != null);
            final isLoading = state.isLoading;
            final errorMessage = state.errorMessage ?? state.failedLocations?.toString();
            return Scaffold(
              body: SafeArea(
                child: Center(
                  child: Padding(
                    padding: LivitContainerStyle.paddingFromScreen,
                    child: GlassContainer(
                      hasPadding: false,
                      titleBarText: locations.length > 1 ? 'Agrega multimedia de tus locaciones' : 'Agrega multimedia de tu locación',
                      child: Flexible(
                        child: Padding(
                          padding: LivitContainerStyle.padding(padding: [0, 0, null, 0]),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: LivitContainerStyle.padding(padding: [0, null, 0, null]),
                                child: LivitText(
                                    'Agrega videos o imagenes de tus locaciones para que tus clientes puedan verlos. La imagen o video principal sera la que se muestre como portada de tu locación.'),
                              ),
                              Flexible(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: LivitContainerStyle.verticalPadding / 2),
                                  child: LivitScrollbar(
                                    thumbVisibility: true,
                                    controller: _scrollController,
                                    child: _locationsScroller(
                                      scrollController: _scrollController,
                                    ),
                                  ),
                                ),
                              ),
                              if (errorMessage != null) ...[
                                LivitSpaces.s,
                                LivitText(errorMessage),
                                LivitSpaces.s,
                              ],
                              Padding(
                                padding: EdgeInsets.only(right: LivitContainerStyle.horizontalPadding),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Button.grayText(
                                      deactivateSplash: true,
                                      isActive: true,
                                      text: isLoading ? 'Completando' : 'Completar más tarde',
                                      isLoading: isLoading,
                                      rightIcon: Icons.arrow_forward_ios,
                                      onPressed: () {
                                        _locations = _locations.map((location) => location.copyWith(media: LivitLocationMedia())).toList();
                                        BlocProvider.of<LocationBloc>(context).add(UpdateLocationsMedia(locations: _locations));
                                      },
                                    ),
                                    Button.main(
                                      isActive: isValid,
                                      text: isLoading ? 'Continuando' : 'Continuar',
                                      isLoading: isLoading,
                                      onPressed: () {
                                        BlocProvider.of<LocationBloc>(context).add(UpdateLocationsMedia(locations: _locations));
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
              ),
            );
          } else {
            return ErrorReauthScreen();
          }
        } catch (e) {
          return ErrorReauthScreen();
        }
      },
    );
  }

  Widget _locationsScroller({required ScrollController scrollController}) {
    return ListView.builder(
      controller: scrollController,
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _locations.length,
      itemBuilder: (context, index) {
        final location = _locations.elementAt(index);
        return Padding(
          padding: LivitContainerStyle.padding(padding: [index != 0 ? 0 : null, null, null, null]),
          child: LocationMediaInputField(
              location: location,
              onMainSelected: _onMainSelected,
              onSecondarySelected: _onSecondarySelected,
              onMediaChanged: _onMediaChanged,
              onMediaReset: _onMediaReset),
        );
      },
    );
  }
}
