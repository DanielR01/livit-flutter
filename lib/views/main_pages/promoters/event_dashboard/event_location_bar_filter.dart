import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/models/location/location.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_state.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';

class EventLocationBarFilter extends StatefulWidget {
  final Function(String?)? onLocationSelected;

  const EventLocationBarFilter({
    super.key,
    this.onLocationSelected,
  });

  @override
  State<EventLocationBarFilter> createState() => _EventLocationBarFilterState();
}

class _EventLocationBarFilterState extends State<EventLocationBarFilter> {
  late final LocationBloc _locationBloc;
  bool _isLocationSelectorExpanded = false;
  String? _selectedLocationId;

  @override
  void initState() {
    super.initState();
    _locationBloc = BlocProvider.of<LocationBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        if (state is! LocationsLoaded) {
          return const LivitBar(
            child: Center(
              child: CupertinoActivityIndicator(),
            ),
          );
        }

        final List<LivitLocation> locations = _locationBloc.locations;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _isLocationSelectorExpanded ? (locations.length + 2) * LivitBarStyle.height : LivitBarStyle.height,
          child: LivitBar(
            shadowType: ShadowType.weak,
            noPadding: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Collapsed view - shows current selection
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
                            _getSelectedLocationName(locations),
                            textType: LivitTextType.normalTitle,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Positioned(
                            right: 0,
                            child: Row(
                              children: [
                                Icon(
                                  _selectedLocationId == null ? CupertinoIcons.calendar_badge_plus : CupertinoIcons.location,
                                  size: LivitButtonStyle.iconSize,
                                  color: LivitColors.whiteActive,
                                ),
                                LivitSpaces.xs,
                                AnimatedRotation(
                                  duration: const Duration(milliseconds: 300),
                                  turns: _isLocationSelectorExpanded ? 0.5 : 0,
                                  child: Icon(
                                    CupertinoIcons.chevron_down,
                                    size: LivitButtonStyle.iconSize,
                                    color: LivitColors.whiteActive,
                                  ),
                                ),
                              ],
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
                            // Header with close button
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
                                      'Filtrar eventos por ubicación',
                                      textType: LivitTextType.normalTitle,
                                      color: LivitColors.whiteActive,
                                      overflow: TextOverflow.ellipsis,
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

                            // "All Events" option
                            LivitBar.touchable(
                              shadowType: ShadowType.none,
                              noPadding: true,
                              onTap: () {
                                setState(() {
                                  _selectedLocationId = null;
                                  _isLocationSelectorExpanded = false;
                                  if (widget.onLocationSelected != null) {
                                    widget.onLocationSelected!(null);
                                  }
                                });
                              },
                              child: Padding(
                                padding: LivitContainerStyle.padding(padding: [0, null, 0, null]),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          CupertinoIcons.calendar_badge_plus,
                                          size: LivitButtonStyle.iconSize,
                                          color: _selectedLocationId == null ? LivitColors.whiteActive : LivitColors.whiteInactive,
                                        ),
                                        LivitSpaces.xs,
                                        LivitText(
                                          'Todos los eventos',
                                          textType: LivitTextType.normalTitle,
                                          color: _selectedLocationId == null ? LivitColors.whiteActive : LivitColors.whiteInactive,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                    if (_selectedLocationId == null)
                                      Positioned(
                                        left: 0,
                                        child: Icon(
                                          CupertinoIcons.checkmark_alt,
                                          size: LivitButtonStyle.iconSize,
                                          color: LivitColors.whiteActive,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),

                            // Location options
                            ...locations.map(
                              (location) => LivitBar.touchable(
                                shadowType: ShadowType.none,
                                noPadding: true,
                                onTap: () {
                                  setState(() {
                                    _selectedLocationId = location.id;
                                    _isLocationSelectorExpanded = false;
                                    if (widget.onLocationSelected != null) {
                                      widget.onLocationSelected!(location.id);
                                    }
                                  });
                                },
                                child: Padding(
                                  padding: LivitContainerStyle.padding(padding: [0, null, 0, null]),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            CupertinoIcons.location,
                                            size: LivitButtonStyle.iconSize,
                                            color: location.id == _selectedLocationId ? LivitColors.whiteActive : LivitColors.whiteInactive,
                                          ),
                                          LivitSpaces.xs,
                                          LivitText(
                                            location.name,
                                            textType: LivitTextType.normalTitle,
                                            color: location.id == _selectedLocationId ? LivitColors.whiteActive : LivitColors.whiteInactive,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      if (location.id == _selectedLocationId)
                                        Positioned(
                                          left: 0,
                                          child: Icon(
                                            CupertinoIcons.checkmark_alt,
                                            size: LivitButtonStyle.iconSize,
                                            color: LivitColors.whiteActive,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
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
      },
    );
  }

  String _getSelectedLocationName(List<LivitLocation> locations) {
    if (_selectedLocationId == null) {
      return 'Todos los eventos';
    }

    final location = locations.firstWhere(
      (loc) => loc.id == _selectedLocationId,
      orElse: () => LivitLocation(
          id: '',
          name: 'Ubicación no encontrada',
          userId: '',
          address: '',
          geopoint: const GeoPoint(0, 0),
          state: '',
          city: '',
          schedule: null),
    );

    return location.name;
  }
}
