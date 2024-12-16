import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/cloud_models/location.dart';
import 'package:livit/cloud_models/user/cloud_user.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/services/firestore_storage/bloc/users/user_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/users/user_state.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/error_screens/error_reauth_screen.dart';
import 'package:livit/utilities/livit_scrollbar.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        try {
          if (state is CurrentUser) {
            CloudPromoter user = state.user as CloudPromoter;
            List<Location?> locations = user.locations!;
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
                              LivitText('Agrega videos o imagenes de tus locaciones para que tus clientes puedan verlos'),
                              Flexible(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: LivitContainerStyle.verticalPadding / 2),
                                  child: LivitScrollbar(
                                    thumbVisibility: true,
                                    controller: _scrollController,
                                    child: _locationsScroller(
                                      scrollController: _scrollController,
                                      locations: locations,
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
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

  Widget _locationsScroller({required ScrollController scrollController, required List<Location?> locations}) {
    return ListView.builder(
      controller: scrollController,
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final location = locations[index];
        return Padding(
          padding: LivitContainerStyle.padding(padding: [index != 0 ? 0 : null, null, null, null]),
          child: _locationMediaInputField(location!),
        );
      },
    );
  }

  Widget _locationMediaInputField(Location location) {
    final bool isLocationMediaEmpty = location.media == null ||
        (location.media!.mainUrl == null && (location.media!.secondaryUrls!.isEmpty || location.media!.secondaryUrls == null));
    return LivitBar(
      noPadding: true,
      child: Column(
        children: [
          Padding(
            padding: LivitContainerStyle.padding(padding: [null, null, 0, null]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    LivitText(
                      location.name,
                      textType: LivitTextType.smallTitle,
                    ),
                  ],
                ),
                Button.secondary(
                  text: 'Agregar',
                  rightIcon: CupertinoIcons.plus_circle,
                  isActive: true,
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Button.whiteText(
                isActive: !isLocationMediaEmpty,
                text: isLocationMediaEmpty ? 'Sin archivos' : 'Ver archivos',
                rightIcon: !isLocationMediaEmpty ? CupertinoIcons.chevron_down : null,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
