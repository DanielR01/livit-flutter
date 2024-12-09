import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/cloud_models/location.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/shadows.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/services/auth/bloc/auth_bloc.dart';
import 'package:livit/services/auth/bloc/auth_event.dart';
import 'package:livit/services/cloud/bloc/users/user_bloc.dart';
import 'package:livit/services/cloud/bloc/users/user_event.dart';
import 'package:livit/services/cloud/bloc/users/user_state.dart';
import 'package:livit/services/location/location_search_service.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/bars_containers_fields/livit_text_field.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/buttons/livit_dropdown_button.dart';
import 'package:livit/utilities/livit_scrollbar.dart';

class AddressPrompt extends StatefulWidget {
  const AddressPrompt({super.key});

  @override
  State<AddressPrompt> createState() => _AddressPromptState();
}

class _AddressPromptState extends State<AddressPrompt> {
  late final TextEditingController _addressController;
  late final TextEditingController _addressNameController;

  List<Map<String, dynamic>> locations = [
    {
      'index': 0,
      'location': null,
      'valid': false,
    },
  ];
  int currentLocationIndex = 0;

  bool _isSearching = false;

  String? selectedState;
  String? selectedCity;
  double? selectedLatitude;
  double? selectedLongitude;

  final List<String> states = [];
  final Map<String, List<String>> citiesByState = {};

  final GlobalKey titleBarKey = GlobalKey();
  final GlobalKey textKey = GlobalKey();
  final GlobalKey bottomRowKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController();
    _addressController.addListener(_addressListener);
    _addressNameController = TextEditingController();
    _addressNameController.addListener(_addressNameListener);
    controller.addListener(() {
      setState(() {
        height = controller.text.length * 10;
      });
    });
    _loadLocationData();
  }

  @override
  void dispose() {
    _addressController.removeListener(_addressListener);
    _addressController.dispose();
    _addressNameController.dispose();
    super.dispose();
  }

  void _addressListener() {
    if ((locations[currentLocationIndex]['location']?.address ?? '') != _addressController.text) {
      _updateLocations();
    }
  }

  void _addressNameListener() {
    if ((locations[currentLocationIndex]['location']?.name ?? '') != _addressNameController.text) {
      _updateLocations();
    }
  }

  void _updateLocations() {
    Location updatedLocation = (locations[currentLocationIndex]['location'] ??
            Location(
              address: _addressController.text,
              name: _addressNameController.text,
              department: selectedState ?? '',
              city: selectedCity ?? '',
              geopoint: null,
            ))
        .copyWith(
      name: _addressNameController.text,
      address: _addressController.text,
      department: selectedState ?? '',
      city: selectedCity ?? '',
    );
    late final bool valid;
    if (RegExp(r'^[a-zA-Z0-9\s]{1,50}$').hasMatch(updatedLocation.name) &&
        _validateDirection(updatedLocation.address) &&
        updatedLocation.department != '' &&
        updatedLocation.city != '') {
      valid = true;
    } else {
      valid = false;
    }
    setState(() {
      locations[currentLocationIndex]['location'] = updatedLocation;
      locations[currentLocationIndex]['valid'] = valid;
    });
  }

  void _updateLocationsIndexes() {
    for (int i = 0; i < locations.length; i++) {
      if (locations[i]['index'] == currentLocationIndex) {
        currentLocationIndex = i;
      }
      locations[i]['index'] = i;
    }
  }

  void _updateFields() {
    final Location? location = locations[currentLocationIndex]['location'];
    _addressController.text = location?.address ?? '';
    _addressNameController.text = location?.name ?? '';
    selectedState = location?.department;
    selectedCity = location?.city;
  }

  bool _validateDirection(String direction) {
    return direction.length >= 5 && RegExp(r'[a-zA-Z]').hasMatch(direction);
  }

  // Future<void> _searchLocation() async {
  //   try {
  //     final fullAddress = '${_addressController.text}, $selectedCity, $selectedState';
  //     final coordinates = await LocationSearchService.searchLocation(fullAddress);

  //     setState(
  //       () {
  //         selectedLatitude = coordinates['latitude'];
  //         selectedLongitude = coordinates['longitude'];
  //       },
  //     );
  //   } catch (e) {
  //     try {
  //       final cityCoordinates = await LocationSearchService.searchLocation('$selectedCity, $selectedState');
  //       setState(() {
  //         selectedLatitude = cityCoordinates['latitude'];
  //         selectedLongitude = cityCoordinates['longitude'];
  //       });
  //     } catch (_) {}
  //   } finally {
  //     if (selectedLatitude != null && selectedLongitude != null) {
  //       BlocProvider.of<UserBloc>(context).add(
  //         SetPromoterUserLocation(
  //           name: _addressNameController.text,
  //           address: _addressController.text,
  //           geopoint: GeoPoint(
  //             selectedLatitude!,
  //             selectedLongitude!,
  //           ),
  //           department: selectedState!,
  //           city: selectedCity!,
  //         ),
  //       );
  //     }
  //   }
  // }

  Future<void> _loadLocationData() async {
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

  double height = 100;
  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: GlassContainer(
            hasPadding: false,
            titleBarText: '¿Dónde estás ubicado?',
            child: Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: LivitContainerStyle.padding(padding: [0, null, 0, null]),
                    child: LivitText(
                      key: textKey,
                      'Agrega todas las ubicaciones que desees, si no tienes un local físico o deseas completar esta información mas tarde, puedes continuar con el siguiente paso eliminando todas las ubicaciones.',
                    ),
                  ),
                  LivitSpaces.s,
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: _locationInput(),
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
    );
  }

  Widget _locationInput() {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is CurrentUser && state.isLoading) {
          _isSearching = true;
        } else {
          _isSearching = false;
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: LivitScrollbar(
                child: _locationsScroller(),
              ),
            ),
            Padding(
              padding: LivitContainerStyle.padding(padding: [LivitContainerStyle.verticalPadding / 2, null, null, null]),
              child: Row(
                key: bottomRowKey,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Button.secondary(
                    text: locations.isNotEmpty ? 'Añadir otra ubicación' : 'Añadir ubicación',
                    onPressed: () {
                      setState(() {
                        locations.add({
                          'index': locations.length,
                          'location': null,
                          'valid': false,
                        });
                      });
                    },
                    isActive: true,
                    rightIcon: CupertinoIcons.plus_circle,
                  ),
                  Button.main(
                    text: _isSearching ? 'Continuando' : 'Continuar',
                    onPressed: BlocProvider.of<UserBloc>(context).add(SetPromoterUserLocationWithoutGeopoint(location: locations.first['location'] as Location)),
                    isActive: !locations.any((location) => location['valid'] == false),
                    isLoading: _isSearching,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _locationsScroller() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final location = locations[index];
        final Widget locationWidget;
        if (currentLocationIndex == location['index']) {
          locationWidget = _locationInputActiveField(location);
        } else {
          locationWidget = _locationInputInactiveField(location);
        }
        return Padding(
          padding: LivitContainerStyle.padding(padding: [
            index == 0
                ? currentLocationIndex == location['index']
                    ? 0
                    : null
                : 0,
            null,
            index == currentLocationIndex
                ? 0
                : index == locations.length - 1
                    ? LivitContainerStyle.verticalPadding / 2
                    : 0,
            null
          ]),
          child: locationWidget,
        );
      },
    );
  }

  Widget _locationInputActiveField(Map<String, dynamic> location) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LivitText(
          'Ponle un nombre a tu ubicación, generalmente es el nombre de tu local, pero si tienes varias ubicaciones, puedes poner el nombre de cada una.',
          color: LivitColors.whiteInactive,
        ),
        LivitSpaces.s,
        LivitTextField(
          controller: _addressNameController,
          hint: 'Nombre de la ubicación',
          bottomCaptionStyle: LivitTextStyle.regularWhiteInactiveText,
          externalIsValid: RegExp(r'^[a-zA-Z0-9\s]{1,50}$').hasMatch(_addressNameController.text),
          unfocusedShadow: RegExp(r'^[a-zA-Z0-9\s]{1,50}$').hasMatch(_addressNameController.text)
              ? LivitTextFieldShadow.weak
              : LivitTextFieldShadow.normal,
        ),
        LivitSpaces.m,
        LivitTextField(
          controller: _addressController,
          hint: 'Ingresa tu dirección',
          bottomCaptionStyle: LivitTextStyle.regularWhiteInactiveText,
          externalIsValid: _validateDirection(_addressController.text),
          unfocusedShadow: RegExp(r'^[a-zA-Z0-9\s]{1,50}$').hasMatch(_addressNameController.text)
              ? LivitTextFieldShadow.weak
              : LivitTextFieldShadow.normal,
        ),
        LivitSpaces.m,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            LivitDropdownButton(
              entries: states
                  .map((state) => DropdownMenuEntry<String>(
                        value: state,
                        label: state,
                      ))
                  .toList(),
              onSelected: (value) {
                setState(() {
                  selectedState = value;
                  selectedCity = null;
                });
                _updateLocations();
              },
              defaultText: 'Departamento',
              isActive: true,
              selectedValue: selectedState == '' ? null : selectedState,
            ),
            LivitSpaces.s,
            LivitDropdownButton(
              entries: (citiesByState[selectedState] ?? [])
                  .map((city) => DropdownMenuEntry<String>(
                        value: city,
                        label: city,
                      ))
                  .toList(),
              onSelected: (value) {
                setState(() {
                  selectedCity = value;
                });
                _updateLocations();
              },
              defaultText: 'Ciudad',
              isActive: (selectedState != null && selectedState != ''),
              selectedValue: selectedCity == '' ? null : selectedCity,
            ),
            LivitSpaces.s,
          ],
        ),
        LivitSpaces.s,
        Button.whiteText(
          width: double.infinity,
          text: 'Eliminar ubicación',
          rightIcon: CupertinoIcons.delete_solid,
          isActive: true,
          onPressed: () {
            setState(() {
              locations.remove(location);
              currentLocationIndex = -1;
              _updateLocationsIndexes();
            });
          },
        ),
        if (location['index'] != locations.length - 1) LivitSpaces.m,
      ],
    );
  }

  Widget _locationInputInactiveField(Map<String, dynamic> location) {
    final locationData = location['location'] as Location?;
    final valid = location['valid'];
    final index = location['index'];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LivitBar(
          noPadding: true,
          shadowType: !valid ? ShadowType.weak : ShadowType.normal,
          child: Padding(
            padding: valid
                ? LivitContainerStyle.padding()
                : EdgeInsets.only(
                    top: LivitContainerStyle.verticalPadding,
                    bottom: LivitContainerStyle.verticalPadding,
                    left: LivitContainerStyle.horizontalPadding - 9.sp,
                    right: LivitContainerStyle.horizontalPadding,
                  ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!valid) ...[
                      Icon(
                        Icons.circle,
                        color: LivitColors.red,
                        size: 6.sp,
                      ),
                      SizedBox(width: 6.sp),
                    ],
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LivitText(
                          locationData == null || locationData.name == '' ? 'Sin nombre' : locationData.name,
                          color: LivitColors.whiteActive,
                          textAlign: TextAlign.left,
                          textType: TextType.smallTitle,
                        ),
                        LivitSpaces.xs,
                        LivitText(
                          locationData == null || locationData.address == '' ? 'Sin dirección' : locationData.address,
                          color: LivitColors.whiteInactive,
                          textAlign: TextAlign.left,
                        ),
                        LivitText(
                          '${locationData == null || locationData.city == '' ? 'Sin ciudad' : locationData.city}, ${locationData == null || locationData.department == '' ? 'sin departamento' : locationData.department}',
                          color: LivitColors.whiteInactive,
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Button.whiteText(
                      bold: false,
                      text: 'Editar',
                      isActive: true,
                      onPressed: () {
                        currentLocationIndex = index;
                        setState(
                          () {
                            _updateFields();
                          },
                        );
                      },
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              locations.remove(location);
                              _updateLocationsIndexes();
                            });
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Padding(
                              padding: EdgeInsets.all(
                                LivitContainerStyle.horizontalPadding / 2,
                              ),
                              child: SizedBox(
                                height: 16.sp,
                                child: Icon(
                                  CupertinoIcons.delete_solid,
                                  color: LivitColors.whiteInactive,
                                  size: 16.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (location['index'] != locations.length - 1) LivitSpaces.m,
      ],
    );
  }
}
