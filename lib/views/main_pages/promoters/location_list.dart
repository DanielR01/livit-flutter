import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/models/location/location.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_event.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_state.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';
import 'package:livit/utilities/dialogs/livit_date_picker.dart';
import 'package:livit/utilities/display/livit_display_area.dart';

class LocationDetailView extends StatefulWidget {
  const LocationDetailView({super.key});

  @override
  State<LocationDetailView> createState() => _LocationDetailViewState();
}

class _LocationDetailViewState extends State<LocationDetailView> {
  LivitLocation? _location;
  List<LivitLocation>? _locations;
  late final LocationBloc _locationBloc;
  List<DateTime>? _selectedDateRange;
  bool _isLocationSelectorExpanded = false;

  @override
  void initState() {
    super.initState();
    _locationBloc = BlocProvider.of<LocationBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🛠️ [LocationDetailView] Building');
    return Scaffold(
      body: LivitDisplayArea(
        child: BlocBuilder<LocationBloc, LocationState>(
          builder: (context, state) {
            if (state is LocationsLoaded) {
              _locations = state.cloudLocations;
              if (_locations != null && _locations!.isNotEmpty) {
                _location ??= _locations!.first;
              }
            } else if (state is LocationUninitialized) {
              BlocProvider.of<LocationBloc>(context).add(InitializeLocationBloc(context));
            }
            if (_location == null) {
              debugPrint('✅ [LocationDetailView] Returning empty location detail view');
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
              debugPrint('✅ [LocationDetailView] Returning location detail view');
              return Column(
                children: [
                  _locationSelectorBar(),
                  LivitSpaces.xs,
                  _locationTicketsCounterBar(),
                  // if (_location!.events!.isEmpty)
                  //   Expanded(
                  //     child: Center(
                  //       child: Column(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: [
                  //           LivitText(
                  //             'Aún no tienes ningún evento en esta ubicación.\n Crea uno para empezar a promocionarla',
                  //             textType: LivitTextType.smallTitle,
                  //           ),
                  //           LivitSpaces.m,
                  //           Button.main(
                  //             rightIcon: CupertinoIcons.add,
                  //             isActive: true,
                  //             text: 'Crear evento',
                  //             onPressed: () {},
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   )
                  // else
                  //   LivitText(
                  //     'Tienes ${_location!.events!.length} eventos en esta ubicación',
                  //     textType: LivitTextType.normalTitle,
                  //   ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _locationSelectorBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _isLocationSelectorExpanded ? (_locations?.length ?? 0) * LivitBarStyle.height + LivitBarStyle.height : LivitBarStyle.height,
      child: LivitBar(
        shadowType: ShadowType.weak,
        noPadding: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current/Selected Location Bar
            if (!_isLocationSelectorExpanded)
              LivitBar.touchable(
                onTap: () {
                  setState(() {
                    _isLocationSelectorExpanded = true;
                  });
                },
                shadowType: ShadowType.none,
                noPadding: true,
                child: Padding(
                  padding: LivitContainerStyle.padding(padding: [0, null, 0, null]),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      LivitText(
                        _location?.name ?? 'Select Location',
                        textType: LivitTextType.normalTitle,
                      ),
                      Positioned(
                        right: 0,
                        child: AnimatedRotation(
                          duration: const Duration(milliseconds: 300),
                          turns: _isLocationSelectorExpanded ? 0.5 : 0,
                          child: Icon(
                            CupertinoIcons.chevron_down,
                            size: LivitButtonStyle.iconSize,
                            color: LivitColors.whiteActive,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Expanded Location List
            if (_isLocationSelectorExpanded)
              Expanded(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _isLocationSelectorExpanded ? 1.0 : 0.0,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LivitBar.touchable(
                          shadowType: ShadowType.none,
                          noPadding: true,
                          onTap: () {
                            setState(() {
                              _isLocationSelectorExpanded = false;
                            });
                          },
                          child: Padding(
                            padding: LivitContainerStyle.padding(padding: [0, null, 0, null]),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                LivitText(
                                  _location!.name,
                                  textType: LivitTextType.normalTitle,
                                  color: LivitColors.whiteActive,
                                ),
                                Positioned(
                                  right: 0,
                                  child: Icon(
                                    CupertinoIcons.chevron_up,
                                    size: LivitButtonStyle.iconSize,
                                    color: LivitColors.whiteActive,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ..._locations?.map(
                              (location) => _location == location
                                  ? const SizedBox.shrink()
                                  : LivitBar.touchable(
                                      shadowType: ShadowType.none,
                                      noPadding: true,
                                      onTap: () {
                                        setState(() {
                                          _location = location;
                                          _isLocationSelectorExpanded = false;
                                        });
                                      },
                                      child: Padding(
                                        padding: LivitContainerStyle.padding(padding: [0, null, 0, null]),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            LivitText(
                                              location.name,
                                              textType: LivitTextType.normalTitle,
                                              color: location == _location ? LivitColors.whiteActive : LivitColors.whiteInactive,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ) ??
                            [],
                        LivitBar.touchable(
                          shadowType: ShadowType.none,
                          noPadding: true,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                LivitText(
                                  'Crear una nueva ubicación',
                                  textType: LivitTextType.smallTitle,
                                  color: LivitColors.whiteInactive,
                                ),
                                LivitSpaces.xs,
                                Icon(
                                  CupertinoIcons.add,
                                  size: LivitButtonStyle.bigIconSize,
                                  color: LivitColors.whiteInactive,
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _isLocationSelectorExpanded = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _locationTicketsCounterBar() {
    return LivitBar(
      shadowType: ShadowType.weak,

      // TODO: Replace with tickets sold
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.tickets,
                    size: LivitButtonStyle.iconSize,
                    color: LivitColors.whiteActive,
                  ),
                  LivitSpaces.xs,
                  LivitText('28 tickets vendidos', textType: LivitTextType.regular),
                ],
              ),
              LivitSpaces.s,
              Flexible(
                child: LivitDatePicker(
                  onSelected: (date) {
                    debugPrint('🛠️ [LocationDetailView] Date selected: $date');
                    if (date != null) {
                      setState(() {
                        _selectedDateRange = date;
                      });
                    }
                  },
                  defaultDate: DateTime.now(),
                  isActive: true,
                  selectedDateRange: _selectedDateRange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
