import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/models/event/event.dart';
import 'package:livit/models/location/location.dart';
import 'package:livit/models/user/cloud_user.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_state.dart';
import 'package:livit/services/firestore_storage/bloc/user/user_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/user/user_state.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';
import 'package:livit/utilities/bars_containers_fields/livit_text_field.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/buttons/livit_dropdown_button.dart';
import 'package:livit/utilities/buttons/toggle_button.dart';
import 'package:livit/utilities/debug/livit_debugger.dart';

class LocationSelector extends StatefulWidget {
  final EventDate eventDate;
  final VoidCallback? onDataChanged;

  const LocationSelector({
    super.key,
    required this.eventDate,
    this.onDataChanged,
  });

  @override
  State<LocationSelector> createState() => LocationSelectorState();
}

class LocationSelectorState extends State<LocationSelector> {
  final _debugger = const LivitDebugger('LocationSelector');

  bool _useExistingLocation = false;
  String? _selectedLocationId;
  String? _selectedLocationName;

  final _viewKey = UniqueKey();

  final String livitAppleMapViewer = "LivitAppleMapViewer";
  final String livitAppleMapPrompt = "LivitAppleMapPrompt";

  GeoPoint? _locationCoordinates;
  List<String> states = [];
  Map<String, List<String>> citiesByState = {};

  String? _selectedState;
  String? _selectedCity;

  MethodChannel? _mapViewerChannel;

  late final TextEditingController _descriptionController;
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;

  Future<void> _loadStatesAndCityData() async {
    final data = await rootBundle.loadString('assets/data/departments_cities.csv');
    final lines = LineSplitter.split(data).skip(1);
    for (var line in lines) {
      final parts = line.split(';');
      final state = parts[2];
      final city = parts[4];
      if (!states.contains(state)) {
        states.add(state);
      }
      if (!citiesByState.containsKey(state)) {
        citiesByState[state] = [];
      }
      citiesByState[state]!.add(city);
    }

    states.sort();
    for (var state in states) {
      citiesByState[state]!.sort();
    }

    setState(() {});
  }

  void _showMap() {
    showDialog(
      barrierColor: LivitColors.mainBlackDialog,
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: Column(
            children: [
              LivitBar(
                shadowType: ShadowType.normal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.map_pin_ellipse,
                      color: LivitColors.whiteActive,
                      size: LivitButtonStyle.iconSize,
                    ),
                    LivitSpaces.xs,
                    Flexible(
                      child: LivitText(
                        'Seleccionar ubicación en el mapa',
                        textType: LivitTextType.smallTitle,
                      ),
                    ),
                  ],
                ),
              ),
              LivitSpaces.m,
              LivitBar(
                shadowType: ShadowType.weak,
                child: LivitText(
                  'Para seleccionar una ubicación, desplazate y deja presionado en el mapa.',
                ),
              ),
              LivitSpaces.s,
              Flexible(
                child: Container(
                  decoration: LivitContainerStyle.decoration,
                  clipBehavior: Clip.hardEdge,
                  child: UiKitView(
                    viewType: livitAppleMapPrompt,
                    onPlatformViewCreated: (int id) {
                      final MethodChannel channel = MethodChannel('${livitAppleMapPrompt}_$id');
                      if (_locationCoordinates == null) {
                        channel.invokeMethod('hoverCurrentLocation');
                      } else {
                        channel.invokeMethod('setLocation', {
                          'latitude': _locationCoordinates!.latitude,
                          'longitude': _locationCoordinates!.longitude,
                          'title': 'Ubicación seleccionada',
                        });
                      }
                      channel.setMethodCallHandler((call) {
                        _debugger.debPrint('Method call: ${call.method}', DebugMessageType.methodCalling);
                        if (call.method == 'locationSelected') {
                          setState(() {
                            _locationCoordinates = GeoPoint(call.arguments['latitude'], call.arguments['longitude']);
                            _updateMapWithCoordinates();
                            _notifyDataChanged();
                          });
                        }

                        return Future.value(null);
                      });
                    },
                  ),
                ),
              ),
              LivitSpaces.m,
              Row(
                children: [
                  Expanded(
                    child: Button.main(
                      isActive: true,
                      text: 'Volver',
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadStatesAndCityData();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _descriptionController = TextEditingController();

    // Add listeners to all controllers
    _nameController.addListener(_notifyDataChanged);
    _addressController.addListener(_notifyDataChanged);
    _descriptionController.addListener(_notifyDataChanged);
  }

  void _notifyDataChanged() {
    if (widget.onDataChanged != null) {
      Future.microtask(() => widget.onDataChanged!());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final bool hasLocationSelected = _useExistingLocation && _selectedLocationId != null;
    final validation = validateLocationData();

    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        return BlocBuilder<LocationBloc, LocationState>(
          builder: (context, locationState) {
            bool hasLocations = false;
            List<String>? locationIds;
            Map<String, LivitLocation> locationsMap = {};

            // Process user state to get location IDs
            if (userState is CurrentUser) {
              if (userState.user is CloudPromoter) {
                final promoter = userState.user as CloudPromoter;
                locationIds = promoter.locations;
                hasLocations = locationIds != null && locationIds.isNotEmpty;
              }
            }

            // Process location state to get location names
            if (locationState is LocationsLoaded && hasLocations) {
              final locationBloc = context.read<LocationBloc>();
              final availableLocations = locationBloc.locations;

              // Create a map of location IDs to location objects
              for (var location in availableLocations) {
                if (locationIds!.contains(location.id)) {
                  locationsMap[location.id] = location;
                }
              }

              // If no locations match, we might still have IDs but no location data
              hasLocations = locationsMap.isNotEmpty;
            }

            return Padding(
              padding: LivitContainerStyle.padding(padding: [null, null, 0, null]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LivitBar(
                    shadowType: ShadowType.weak,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.tag,
                              color: LivitColors.whiteActive,
                              size: LivitButtonStyle.iconSize,
                            ),
                            LivitSpaces.xs,
                            LivitText(
                              widget.eventDate.name,
                              textType: LivitTextType.smallTitle,
                            ),
                          ],
                        ),
                        Icon(
                          Icons.circle,
                          color: validation['isValid'] == false ? LivitColors.red : LivitColors.mainBlueActive,
                          size: LivitButtonStyle.iconSize / 2,
                        ),
                      ],
                    ),
                  ),
                  LivitSpaces.s,
                  Padding(
                    padding: LivitContainerStyle.padding(padding: [0, null, 0, null]),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: LivitText(
                            'Usar una de mis ubicaciones',
                            textType: LivitTextType.regular,
                            color: LivitColors.whiteActive,
                          ),
                        ),
                        ToggleButton(
                          initialValue: false,
                          onToggle: (value) {
                            setState(() {
                              _useExistingLocation = value;
                            });
                            _notifyDataChanged();
                          },
                        ),
                      ],
                    ),
                  ),
                  LivitSpaces.s,
                  if (!hasLocations && _useExistingLocation) ...[
                    LivitSpaces.s,
                    Container(
                      width: double.infinity,
                      padding: LivitContainerStyle.padding(),
                      decoration: LivitContainerStyle.decoration,
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.info_circle,
                            color: LivitColors.whiteInactive,
                            size: LivitButtonStyle.iconSize,
                          ),
                          LivitSpaces.xs,
                          Expanded(
                            child: LivitText(
                              'No tienes ubicaciones guardadas. Crea al menos una ubicación en tu perfil para usar esta opción.',
                              textType: LivitTextType.small,
                              color: LivitColors.whiteInactive,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (hasLocations && _useExistingLocation) ...[
                    _buildLocationDropdown(locationsMap),
                  ],
                  if (!_useExistingLocation) ...[
                    _buildCustomLocation(),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLocationDropdown(Map<String, LivitLocation> locationsMap) {
    final entries = locationsMap.entries.map((entry) {
      return DropdownMenuEntry(value: entry.key, label: entry.value.name);
    }).toList();
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: LivitDropdownButton(
                entries: entries,
                onSelected: (value) {
                  setState(() {
                    _selectedLocationId = value;
                    _selectedLocationName = locationsMap[value]?.name;
                  });
                  _notifyDataChanged();
                },
                defaultText: 'Seleccionar ubicación',
                isActive: true,
                selectedValue: _selectedLocationName,
              ),
            ),
          ],
        ),
        LivitSpaces.s,
        _buildDescriptionTextField(),
      ],
    );
  }

  Widget _buildCustomLocation() {
    final validation = validateLocationData();

    return Column(
      children: [
        LivitTextField(
          hint: 'Nombre de la ubicación',
          controller: _nameController,
          bottomCaptionText: validation['isNameValid'] == false ? 'Nombre requerido (máx. 50 caracteres)' : null,
          onChanged: (value) {
            setState(() {});
            _notifyDataChanged();
          },
          onClear: () {
            setState(() {
              _nameController.clear();
            });
            _notifyDataChanged();
          },
          externalIsValid: validation['isNameValid'],
        ),
        LivitSpaces.s,
        LivitTextField(
          hint: 'Dirección de la ubicación',
          controller: _addressController,
          bottomCaptionText: validation['isAddressValid'] == false ? 'Dirección necesaria (máx. 100 caracteres)' : null,
          onChanged: (value) {
            setState(() {});
            _notifyDataChanged();
          },
          onClear: () {
            setState(() {
              _addressController.clear();
            });
            _notifyDataChanged();
          },
          externalIsValid: validation['isAddressValid'],
        ),
        LivitSpaces.s,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: LivitDropdownButton(
                entries: states
                    .map(
                      (state) => DropdownMenuEntry<String>(
                        value: state,
                        label: state,
                      ),
                    )
                    .toList(),
                onSelected: (value) {
                  if (value == _selectedState) return;
                  setState(() {
                    _selectedState = value;
                    _selectedCity = null;
                  });
                  _notifyDataChanged();
                },
                defaultText: 'Departamento',
                isActive: true,
                selectedValue: _selectedState == '' ? null : _selectedState,
              ),
            ),
            LivitSpaces.s,
            Expanded(
              child: LivitDropdownButton(
                entries: (citiesByState[_selectedState] ?? [])
                    .map(
                      (city) => DropdownMenuEntry<String>(
                        value: city,
                        label: city,
                      ),
                    )
                    .toList(),
                onSelected: (value) {
                  setState(() {
                    _selectedCity = value;
                  });
                  _notifyDataChanged();
                },
                defaultText: 'Ciudad',
                isActive: (_selectedState != '' && _selectedState != null),
                selectedValue: _selectedCity == '' ? null : _selectedCity,
              ),
            ),
          ],
        ),
        LivitSpaces.s,
        LivitBar(
          shadowType: ShadowType.weak,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.map_pin,
                    color: LivitColors.whiteActive,
                    size: LivitButtonStyle.iconSize,
                  ),
                  LivitSpaces.xs,
                  LivitText(
                    'Ubicación en el mapa',
                    textType: LivitTextType.smallTitle,
                  ),
                ],
              ),
              LivitSpaces.xs,
              LivitText(
                'Para seleccionar o editar la ubicación, presiona el mapa.',
                textType: LivitTextType.small,
                color: LivitColors.whiteInactive,
              ),
              LivitSpaces.xs,
              GestureDetector(
                onTap: () {
                  _showMap();
                },
                child: Container(
                  decoration: LivitContainerStyle.decoration,
                  clipBehavior: Clip.hardEdge,
                  height: 200,
                  child: IgnorePointer(
                    ignoring: true,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        UiKitView(
                          key: _viewKey,
                          viewType: livitAppleMapViewer,
                          onPlatformViewCreated: (int id) {
                            _mapViewerChannel = MethodChannel('${livitAppleMapViewer}_$id');

                            if (_locationCoordinates != null) {
                              _updateMapWithCoordinates();
                            } else {
                              _mapViewerChannel!.invokeMethod('hoverCurrentLocation');
                              _mapViewerChannel!.invokeMethod('hideCurrentLocationMarker');
                            }
                          },
                        ),
                        if (_locationCoordinates == null)
                          Padding(
                            padding: LivitContainerStyle.padding(),
                            child: LivitBar(
                              shadowType: ShadowType.weak,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    CupertinoIcons.map_pin_slash,
                                    color: LivitColors.whiteActive,
                                    size: LivitButtonStyle.iconSize,
                                  ),
                                  LivitSpaces.xs,
                                  Flexible(
                                    child: LivitText('Aun no has seleccionado una ubicación'),
                                  ),
                                  Icon(
                                    CupertinoIcons.exclamationmark_triangle,
                                    color: LivitColors.yellowError,
                                    size: LivitButtonStyle.iconSize,
                                  ),
                                ],
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
        LivitSpaces.s,
        _buildDescriptionTextField(),
      ],
    );
  }

  Widget _buildDescriptionTextField() {
    final validation = validateLocationData();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LivitText(
          'Si deseas agregar una descripción o notas sobre la ubicación para tus clientes, puedes hacerlo aquí.',
          color: LivitColors.whiteInactive,
        ),
        LivitSpaces.s,
        LivitTextField(
          hint: 'Descripción o notas sobre la ubicación (opcional)',
          controller: _descriptionController,
          isMultiline: true,
          bottomCaptionWidget: _buildBottomCaptionCharCount(),
          onChanged: (value) {
            setState(() {});
            _notifyDataChanged();
          },
          externalIsValid: validation['isDescriptionValid'],
        ),
      ],
    );
  }

  Widget _buildBottomCaptionCharCount() {
    int charCount = _descriptionController.text.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LivitSpaces.s,
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            LivitText('$charCount/200 caracteres',
                textType: LivitTextType.regular, color: charCount > 200 ? LivitColors.yellowError : LivitColors.whiteInactive),
          ],
        ),
      ],
    );
  }

  void _updateMapWithCoordinates() {
    if (_locationCoordinates != null && _mapViewerChannel != null) {
      _mapViewerChannel!.invokeMethod('setLocation', {
        'latitude': _locationCoordinates!.latitude,
        'longitude': _locationCoordinates!.longitude,
        'title': 'Ubicación seleccionada',
      });
    }
  }

  Map<String, dynamic> validateLocationData() {
    if (_useExistingLocation) {
      // Validate existing location selection
      final bool isValid = _selectedLocationId != null;
      return {
        'isValid': isValid,
        'message': isValid ? null : 'Selecciona una ubicación',
      };
    } else {
      // Validate custom location
      final bool isNameValid = _nameController.text.trim().isNotEmpty && _nameController.text.length <= 50;
      final bool isAddressValid = _addressController.text.trim().isNotEmpty && _addressController.text.length <= 100;
      final bool isStateValid = _selectedState != null && _selectedState!.isNotEmpty;
      final bool isCityValid = _selectedCity != null && _selectedCity!.isNotEmpty;
      final bool isGeoPointValid = _locationCoordinates != null;
      final bool isDescriptionValid = _descriptionController.text.length <= 200;

      final bool isValid = isNameValid && isAddressValid && isStateValid && isCityValid && isGeoPointValid && isDescriptionValid;

      String? message;
      if (!isNameValid) {
        message = 'El nombre debe tener entre 1 y 50 caracteres';
      } else if (!isAddressValid) {
        message = 'La dirección debe tener entre 1 y 100 caracteres';
      } else if (!isStateValid) {
        message = 'Selecciona un departamento';
      } else if (!isCityValid) {
        message = 'Selecciona una ciudad';
      } else if (!isGeoPointValid) {
        message = 'Selecciona una ubicación en el mapa';
      } else if (!isDescriptionValid) {
        message = 'La descripción no puede superar los 200 caracteres';
      }

      return {
        'isValid': isValid,
        'isNameValid': isNameValid,
        'isAddressValid': isAddressValid,
        'isStateValid': isStateValid,
        'isCityValid': isCityValid,
        'isGeoPointValid': isGeoPointValid,
        'isDescriptionValid': isDescriptionValid,
        'message': message,
      };
    }
  }

  // Get complete location data from this selector
  Map<String, dynamic> getLocationData() {
    return {
      'useExisting': _useExistingLocation,
      'locationId': _selectedLocationId,
      'locationName': _selectedLocationName,
      'customName': _nameController.text,
      'address': _addressController.text,
      'state': _selectedState,
      'city': _selectedCity,
      'geopoint': _locationCoordinates,
      'description': _descriptionController.text,
    };
  }
}
