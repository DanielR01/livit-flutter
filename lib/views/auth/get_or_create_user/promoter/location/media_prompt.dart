import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/cloud_models/location/location.dart';
import 'package:livit/cloud_models/location/location_media.dart';
import 'package:livit/cloud_models/location/location_media_file.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/services/firestore_storage/bloc/locations/location_bloc.dart';
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
          locationToUpdate.copyWith(media: locationToUpdate.media?.copyWith(mainFile: file) ?? LocationMedia(mainFile: file));
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
              LocationMedia(secondaryFiles: [file]));
      setState(() {
        _locations[index] = updatedLocation;
      });
    }
  }

  void _onMainDeleted(LivitLocationMediaFile file, Location location) {}

  void _onSecondaryDeleted(LivitLocationMediaFile file, Location location) {}

  void _onMediaReset(Location location) {
    final index = _locations.indexWhere((element) => element.id == location.id);
    if (index != -1) {
      setState(() {
        _locations[index] = location.copyWith(media: null);
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Button.grayText(
                                    isActive: true,
                                    text: 'Completar más tarde',
                                    onPressed: () {},
                                  ),
                                  Button.main(
                                    isActive: true,
                                    text: 'Continuar',
                                    onPressed: () {},
                                  ),
                                ],
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
              onMainDeleted: _onMainDeleted,
              onSecondaryDeleted: _onSecondaryDeleted,
              onMediaReset: _onMediaReset),
        );
      },
    );
  }
}
