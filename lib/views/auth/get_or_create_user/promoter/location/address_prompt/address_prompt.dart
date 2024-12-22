import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/cloud_models/location/location.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/services/firestore_storage/bloc/locations/location_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/locations/location_event.dart';
import 'package:livit/services/firestore_storage/bloc/locations/location_state.dart';
import 'package:livit/services/firestore_storage/firestore_storage/exceptions/firestore_exceptions.dart';
import 'package:livit/utilities/background/main_background.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/error_screens/error_reauth_screen.dart';
import 'package:livit/utilities/livit_scrollbar.dart';
import 'package:livit/views/auth/get_or_create_user/promoter/location/address_prompt/location_address_prompt_field.dart';

class AddressPrompt extends StatefulWidget {
  const AddressPrompt({super.key});

  @override
  State<AddressPrompt> createState() => _AddressPromptState();
}

class _AddressPromptState extends State<AddressPrompt> {
  List<Location> _locations = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  double height = 100;
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        if (state is! LocationsLoaded) {
          return ErrorReauthScreen(exception: UserInformationCorruptedException());
        }

        _locations = BlocProvider.of<LocationBloc>(context).locations;
        final isValid = _locations.every((location) => location.media?.mainFile?.filePath != null);
        final isCloudLoading = LocationBloc().isCloudLoading;
        final errorMessage = state.errorMessage ?? state.failedLocations?.toString();

        return Scaffold(
          body: Stack(
            children: [
              MainBackground.colorful(blurred: false),
              SafeArea(
                child: Center(
                  child: Padding(
                    padding: LivitContainerStyle.paddingFromScreen,
                    child: GlassContainer(
                      hasPadding: false,
                      titleBarText: '¿Dónde estás ubicado?',
                      child: Flexible(
                        child: Padding(
                          padding: LivitContainerStyle.padding(padding: [0, 0, null, 0]),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: LivitContainerStyle.padding(padding: [0, null, 0, null]),
                                child: LivitText(
                                  'Agrega todas las ubicaciones que desees, si no tienes un local físico o deseas completar esta información mas tarde, puedes continuar con el siguiente paso eliminando todas las ubicaciones.',
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
                                      text: isCloudLoading ? 'Completando' : 'Completar más tarde',
                                      isLoading: isCloudLoading,
                                      rightIcon: Icons.arrow_forward_ios,
                                      onPressed: () {
                                        // TODO: Implement this
                                      },
                                    ),
                                    Button.main(
                                      isActive: isValid,
                                      text: isCloudLoading ? 'Continuando' : 'Continuar',
                                      isLoading: isCloudLoading,
                                      onPressed: () {
                                        // TODO: Implement this
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
            ],
          ),
        );
      },
    );
  }

  Widget _locationsScroller({required ScrollController scrollController}) {
    return ListView.builder(
      controller: scrollController,
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _locations.length + 1,
      itemBuilder: (context, index) {
        if (index == _locations.length) {
          return Padding(
            padding: LivitContainerStyle.padding(padding: [0, null, null, null]),
            child: SizedBox(
              width: double.infinity,
              child: Button.secondary(
                text: 'Añadir ubicación',
                onPressed: () {
                  BlocProvider.of<LocationBloc>(context).add(
                    CreateLocationLocally(
                      location: Location.empty(),
                    ),
                  );
                },
                isActive: true,
                rightIcon: CupertinoIcons.plus_circle,
              ),
            ),
          );
        }
        final location = _locations.elementAt(index);
        return Padding(
          padding: LivitContainerStyle.padding(padding: [index != 0 ? 0 : null, null, null, null]),
          child: LocationAddressPromptField(location: location),
        );
      },
    );
  }
}
