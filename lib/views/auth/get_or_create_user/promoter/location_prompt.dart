import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/services/cloud/bloc/users/user_bloc.dart';
import 'package:livit/services/cloud/bloc/users/user_event.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/bars_containers_fields/title_bar.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/map_viewer.dart';

class LocationPromptView extends StatefulWidget {
  const LocationPromptView({super.key});

  @override
  State<LocationPromptView> createState() => _LocationPromptViewState();
}

class _LocationPromptViewState extends State<LocationPromptView> {
  double? selectedLatitude;
  double? selectedLongitude;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: LivitContainerStyle.paddingFromScreen,
          child: GlassContainer(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const TitleBar(title: '¿Dónde estás ubicado?'),
                Padding(
                  padding: LivitContainerStyle.padding(padding: [0, null, null, null]),
                  child: Column(
                    children: [
                      const LivitText(
                        'Selecciona tu ubicación manteniendo presionado en el mapa. Esta ubicación será usada para mostrar a tus clientes dónde estás.',
                      ),
                      LivitSpaces.m,
                      Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: LivitContainerStyle.decoration,
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: LivitAppleMapView(
                          onLocationSelected: (location) {
                            setState(() {
                              selectedLatitude = location['latitude'];
                              selectedLongitude = location['longitude'];
                            });
                          },
                        ),
                      ),
                      LivitSpaces.m,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Button.grayText(
                                text: 'Completar más tarde',
                                onPressed: () {
                                  
                                },
                                isActive: true,
                                
                                rightIcon: Icons.arrow_forward_ios,
                              ),
                              Button.main(
                                text: 'Continuar',
                                onPressed: () {
                                  BlocProvider.of<UserBloc>(context).add(SetPromoterUserLocation(latitude: selectedLatitude!, longitude: selectedLongitude!));
                                },
                                isActive: selectedLatitude != null && selectedLongitude != null,
                              ),
                            ],
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
