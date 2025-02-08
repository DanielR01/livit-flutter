import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/models/location/location.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_event.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_state.dart';
import 'package:livit/services/firestore_storage/bloc/user/user_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/user/user_event.dart';
import 'package:livit/services/firestore_storage/bloc/user/user_state.dart';
import 'package:livit/services/firestore_storage/firestore_storage/exceptions/firestore_exceptions.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/bars_containers_fields/keyboard_dismissible.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/display/livit_display_area.dart';
import 'package:livit/utilities/error_screens/error_reauth_screen.dart';
import 'package:livit/utilities/livit_scrollbar.dart';
import 'package:livit/views/auth/get_or_create_user/promoter/location/address_prompt/location_address_prompt_field.dart';

class AddressPrompt extends StatefulWidget {
  const AddressPrompt({super.key});

  @override
  State<AddressPrompt> createState() => _AddressPromptState();
}

class _AddressPromptState extends State<AddressPrompt> {
  List<LivitLocation> _locations = [];

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
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is! CurrentUser) {
          return const SizedBox.shrink();
        }
        final isUserLoading = state.isLoading;
        String? errorMessage = state.exception?.toString();
        return BlocBuilder<LocationBloc, LocationState>(
          builder: (context, state) {
            if (state is! LocationsLoaded) {
              return ErrorReauthScreen(exception: UserInformationCorruptedException());
            }
            final locationBloc = BlocProvider.of<LocationBloc>(context);
            _locations = locationBloc.locations;
            final isValid = locationBloc.areAllLocationsValidWithoutMedia &&
                (state.localUnsavedLocations.isNotEmpty || state.localSavedLocations.isNotEmpty || state.cloudLocations.isNotEmpty);
            final isCloudLoading =
                locationBloc.isCloudLoading && (state.localUnsavedLocations.isNotEmpty || state.localSavedLocations.isNotEmpty);
            errorMessage = errorMessage != null || state.failedLocations?.isNotEmpty == true ? 'Error al crear las ubicaciones' : null;
            return KeyboardDismissible(
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                body: LivitDisplayArea(
                  child: Center(
                    child: GlassContainer(
                      hasPadding: false,
                      titleBarText: 'Agrega tus ubicaciones',
                      child: Flexible(
                        child: Padding(
                          padding: LivitContainerStyle.padding(padding: [0, 0, null, 0]),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: LivitContainerStyle.padding(padding: [0, null, 0, null]),
                                child: LivitText(
                                  'Agrega todas las ubicaciones que desees, si no tienes un local físico o deseas completar esta información mas tarde, puedes continuar con el siguiente paso.',
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
                                LivitText(errorMessage!),
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
                                      text: isUserLoading ? 'Completando' : 'Completar más tarde',
                                      isLoading: isUserLoading,
                                      rightIcon: Icons.arrow_forward_ios,
                                      onPressed: () {
                                        BlocProvider.of<UserBloc>(context).add(
                                          SetPromoterUserNoLocations(context),
                                        );
                                      },
                                    ),
                                    Button.main(
                                      isActive: isValid,
                                      text: isCloudLoading ? 'Continuando' : 'Continuar',
                                      isLoading: isCloudLoading,
                                      onTap: () {
                                        debugPrint('📤 [AddressPrompt] Creating locations to cloud from local');
                                        BlocProvider.of<LocationBloc>(context).add(
                                          CreateLocationsToCloudFromLocal(context),
                                        );
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
          },
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
            padding: LivitContainerStyle.padding(padding: [index != 0 ? 0 : null, null, null, null]),
            child: SizedBox(
              width: double.infinity,
              child: Button.secondary(
                text: 'Añadir ubicación',
                onTap: () {
                  BlocProvider.of<LocationBloc>(context).add(
                    CreateLocationLocally(
                      context,
                      location: LivitLocation.empty(),
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
