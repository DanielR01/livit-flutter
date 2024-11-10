import 'dart:collection';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/services/cloud/bloc/users/user_bloc.dart';
import 'package:livit/services/cloud/bloc/users/user_event.dart';
import 'package:livit/services/location/location_search_service.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/bars_containers_fields/livit_text_field.dart';
import 'package:livit/utilities/bars_containers_fields/title_bar.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/buttons/livit_dropdown_button.dart';
import 'package:livit/utilities/map_viewer.dart';

class LocationPromptView extends StatefulWidget {
  const LocationPromptView({super.key});

  @override
  State<LocationPromptView> createState() => _LocationPromptViewState();
}

class _LocationPromptViewState extends State<LocationPromptView> {
  late final TextEditingController _directionController;
  bool _isDirectionValid = false;
  bool _isSearching = false;
  bool _showMap = false;
  String? selectedState;
  String? selectedCity;
  double? selectedLatitude;
  double? selectedLongitude;

  final List<String> states = [];
  final Map<String, List<String>> citiesByState = {};

  @override
  void initState() {
    super.initState();
    _directionController = TextEditingController();
    _directionController.addListener(_validateDirection);
    _loadLocationData();
  }

  @override
  void dispose() {
    _directionController.removeListener(_validateDirection);
    _directionController.dispose();
    super.dispose();
  }

  void _validateDirection() {
    setState(() {
      _isDirectionValid = _directionController.text.length >= 5 && RegExp(r'[a-zA-Z]').hasMatch(_directionController.text);
    });
  }

  Future<void> _searchLocation() async {
    if (!_isDirectionValid || selectedState == null || selectedCity == null) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final fullAddress = '${_directionController.text}, $selectedCity, $selectedState';
      final coordinates = await LocationSearchService.searchLocation(fullAddress);

      setState(
        () {
          selectedLatitude = coordinates['latitude'];
          selectedLongitude = coordinates['longitude'];
        },
      );
    } catch (e) {
      try {
        final cityCoordinates = await LocationSearchService.searchLocation('$selectedCity, $selectedState');
        setState(() {
          selectedLatitude = cityCoordinates['latitude'];
          selectedLongitude = cityCoordinates['longitude'];
        });
      } catch (_) {}
    } finally {
      if (selectedLatitude != null && selectedLongitude != null) {
        setState(
          () {
            _isSearching = false;
            _showMap = true;
          },
        );
      }
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: LivitContainerStyle.paddingFromScreen,
            child: GlassContainer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const TitleBar(title: '¿Dónde estás ubicado?'),
                  Flexible(
                    child: Padding(
                      padding: LivitContainerStyle.padding(padding: [0, null, null, null]),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LivitTextField(
                            controller: _directionController,
                            hint: 'Ingresa tu dirección',
                            bottomCaptionStyle: LivitTextStyle.regularWhiteInactiveText,
                            externalIsValid: _isDirectionValid,
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
                                },
                                defaultText: 'Departamento',
                                isActive: true,
                                selectedValue: selectedState,
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
                                },
                                defaultText: 'Ciudad',
                                isActive: selectedState != null,
                                selectedValue: selectedCity,
                              ),
                            ],
                          ),
                          LivitSpaces.m,
                          Button.main(
                            text: _isSearching ? 'Buscando' : 'Continuar',
                            onPressed: _searchLocation,
                            isActive: selectedState != null && selectedCity != null && _isDirectionValid && !_isSearching,
                            isLoading: _isSearching,
                          ),
                          if (_showMap) ...[
                            LivitSpaces.m,
                            Flexible(
                              child: Container(
                                clipBehavior: Clip.hardEdge,
                                decoration: LivitContainerStyle.decoration,
                                child: LivitMapView(
                                  latitude: selectedLatitude!,
                                  longitude: selectedLongitude!,
                                  onLocationSelected: (location) {
                                    setState(() {
                                      selectedLatitude = location['latitude'];
                                      selectedLongitude = location['longitude'];
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
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
}
