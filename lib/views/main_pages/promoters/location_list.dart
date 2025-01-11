import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/cloud_models/location/location.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/services/firestore_storage/bloc/locations/location_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/locations/location_event.dart';
import 'package:livit/services/firestore_storage/bloc/locations/location_state.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';
import 'package:livit/utilities/display/livit_display_area.dart';

class LocationDetailView extends StatefulWidget {
  const LocationDetailView({super.key});

  @override
  State<LocationDetailView> createState() => _LocationDetailViewState();
}

class _LocationDetailViewState extends State<LocationDetailView> {
  LivitLocation? _location;
  List<LivitLocation> _locations = [];
  late final LocationBloc _locationBloc;

  @override
  void initState() {
    super.initState();
    _locationBloc = BlocProvider.of<LocationBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LivitDisplayArea(
        child: BlocBuilder<LocationBloc, LocationState>(
          builder: (context, state) {
            if (state is LocationsLoaded) {
              _locations = state.cloudLocations;
              if (_locations.isNotEmpty) {
                _location ??= _locations.first;
              }
            } else if (state is LocationUninitialized) {
              BlocProvider.of<LocationBloc>(context).add(InitializeLocationBloc(context));
            }
            if (_location == null) {
              return Column(
                children: [
                  LivitBar(
                    shadowType: ShadowType.strong,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LivitText(
                          'Crear una ubicación',
                          textType: LivitTextType.smallTitle,
                        ),
                        LivitSpaces.s,
                        Icon(
                          CupertinoIcons.add_circled,
                          size: LivitButtonStyle.bigIconSize,
                          color: LivitColors.whiteActive,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: LivitText(
                        'Aún no tienes ninguna ubicación. Crea una para empezar a promocionarla',
                        textType: LivitTextType.normalTitle,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LivitBar(
                    child: LivitText(_location!.name, textType: LivitTextType.smallTitle),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            color: Colors.red,
                            height: 100,
                            width: 100,
                          ),
                          LivitSpaces.s,
                          Container(
                            color: Colors.red,
                            height: 100,
                            width: 100,
                          ),
                          LivitSpaces.s,
                          Container(
                            color: Colors.red,
                            height: 100,
                            width: 100,
                          ),
                          LivitSpaces.s,
                          Container(
                            color: Colors.red,
                            height: 100,
                            width: 100,
                          ),
                          LivitSpaces.s,
                          Container(
                            color: Colors.red,
                            height: 100,
                            width: 100,
                          ),
                          LivitSpaces.s,
                          Container(
                            color: Colors.red,
                            height: 100,
                            width: 100,
                          ),
                          LivitSpaces.s,
                          Container(
                            color: Colors.red,
                            height: 100,
                            width: 100,
                          ),
                          LivitSpaces.s,
                          Container(
                            color: Colors.red,
                            height: 100,
                            width: 100,
                          ),
                          LivitSpaces.s,
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
