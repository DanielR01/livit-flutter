import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/cloud_models/location/location.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/services/firestore_storage/bloc/locations/location_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/locations/location_event.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';
import 'package:livit/utilities/bars_containers_fields/livit_text_field.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/buttons/livit_dropdown_button.dart';

class LocationAddressPromptField extends StatefulWidget {
  final Location location;
  const LocationAddressPromptField({super.key, required this.location});

  @override
  State<LocationAddressPromptField> createState() => _LocationAddressPromptFieldState();
}

class _LocationAddressPromptFieldState extends State<LocationAddressPromptField> {
  bool isEditing = false;
  final Duration _animationDuration = const Duration(milliseconds: 300);

  bool isValid = false;

  late final TextEditingController _addressController;
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  List<String> states = [];
  Map<String, List<String>> citiesByState = {};

  late final double _addressContainerHeight;

  final _addressControllerKey = GlobalKey();
  final _nameControllerKey = GlobalKey();
  final _descriptionControllerKey = GlobalKey();
  final _stateCityControllerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.location.address);
    _nameController = TextEditingController(text: widget.location.name);
    _descriptionController = TextEditingController(text: widget.location.description);

    _addressController.addListener(() {
      BlocProvider.of<LocationBloc>(context).add(
        UpdateLocationLocally(
          location: widget.location.copyWith(address: _addressController.text),
        ),
      );
    });

    _nameController.addListener(() {
      BlocProvider.of<LocationBloc>(context).add(
        UpdateLocationLocally(
          location: widget.location.copyWith(name: _nameController.text),
        ),
      );
    });

    _descriptionController.addListener(() {
      BlocProvider.of<LocationBloc>(context).add(
        UpdateLocationLocally(
          location: widget.location.copyWith(description: _descriptionController.text),
        ),
      );
    });

    _loadStatesAndCityData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateAddressContainerHeight();
    });

    locationBloc = BlocProvider.of<LocationBloc>(context);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  late final LocationBloc locationBloc;
  late Map<String, bool> isLocationValid;

  void _calculateAddressContainerHeight() {
    final addressContainerHeight = _addressControllerKey.currentContext?.size?.height ?? 0;
    final nameContainerHeight = _nameControllerKey.currentContext?.size?.height ?? 0;
    final descriptionContainerHeight = _descriptionControllerKey.currentContext?.size?.height ?? 0;
    final spacesHeight = LivitSpaces.sDouble * 4;
    final paddingHeight = LivitContainerStyle.verticalPadding * 2;
    final stateCityContainerHeight = _stateCityControllerKey.currentContext?.size?.height ?? 0;
    _addressContainerHeight =
        addressContainerHeight + nameContainerHeight + descriptionContainerHeight + spacesHeight + paddingHeight + stateCityContainerHeight;
  }

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

  Widget addressContainer() {
    return Padding(
      padding: LivitContainerStyle.padding(padding: null),
      child: Column(
        children: [
          LivitTextField(
            key: _nameControllerKey,
            controller: _nameController,
            hint: 'Nombre',
            externalIsValid: isLocationValid['isNameValid'] as bool,
          ),
          LivitSpaces.s,
          LivitTextField(
            key: _addressControllerKey,
            controller: _addressController,
            hint: 'Dirección',
            externalIsValid: isLocationValid['isAddressValid'] as bool,
          ),
          LivitSpaces.s,
          LivitTextField(
            key: _descriptionControllerKey,
            controller: _descriptionController,
            hint: 'Descripción',
            isMultiline: true,
            lines: 2,
            bottomCaptionWidget: _buildBottomCaptionCharCount(),
            externalIsValid: isLocationValid['isDescriptionValid'] as bool,
          ),
          LivitSpaces.s,
          Row(
            key: _stateCityControllerKey,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              LivitDropdownButton(
                entries: states
                    .map(
                      (state) => DropdownMenuEntry<String>(
                        value: state,
                        label: state,
                      ),
                    )
                    .toList(),
                onSelected: (value) {
                  BlocProvider.of<LocationBloc>(context).add(
                    UpdateLocationLocally(
                      location: widget.location.copyWith(department: value, city: ''),
                    ),
                  );
                },
                defaultText: 'Departamento',
                isActive: true,
                selectedValue: widget.location.department == '' ? null : widget.location.department,
              ),
              LivitSpaces.s,
              LivitDropdownButton(
                entries: (citiesByState[widget.location.department] ?? [])
                    .map(
                      (city) => DropdownMenuEntry<String>(
                        value: city,
                        label: city,
                      ),
                    )
                    .toList(),
                onSelected: (value) {
                  BlocProvider.of<LocationBloc>(context).add(
                    UpdateLocationLocally(
                      location: widget.location.copyWith(city: value),
                    ),
                  );
                },
                defaultText: 'Ciudad',
                isActive: (widget.location.department != ''),
                selectedValue: widget.location.city == '' ? null : widget.location.city,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    isLocationValid = locationBloc.isLocationValid(widget.location);
    return LivitBar(
      noPadding: true,
      shadowType: isLocationValid['isValidWithoutMedia'] as bool ? ShadowType.weak : ShadowType.strong,
      child: Column(
        children: [
          LivitBar(
            shadowType: isEditing ? ShadowType.weak : ShadowType.strong,
            noPadding: true,
            child: InkWell(
              onTap: () {
                setState(() {
                  isEditing = !isEditing;
                });
                final currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
              },
              child: Column(
                children: [
                  Padding(
                    padding: LivitContainerStyle.padding(padding: [null, null, 0, null]),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.circle,
                                color: isLocationValid['isValidWithoutMedia'] as bool ? LivitColors.mainBlueActive : LivitColors.red,
                                size: 6.sp,
                              ),
                              SizedBox(width: 6.sp),
                              Flexible(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    LivitText(
                                      widget.location.name == '' ? 'Sin nombre' : widget.location.name,
                                      color: LivitColors.whiteActive,
                                      textAlign: TextAlign.left,
                                      textType: LivitTextType.smallTitle,
                                    ),
                                    LivitSpaces.xs,
                                    LivitText(
                                      widget.location.address == '' ? 'Sin dirección' : widget.location.address,
                                      color: LivitColors.whiteInactive,
                                      textAlign: TextAlign.left,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    LivitText(
                                      '${widget.location.city == '' ? 'Sin ciudad' : widget.location.city}, ${widget.location.department == '' ? 'sin departamento' : widget.location.department}',
                                      color: LivitColors.whiteInactive,
                                      textAlign: TextAlign.left,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                BlocProvider.of<LocationBloc>(context).add(
                                  DeleteLocationLocally(
                                    location: widget.location,
                                  ),
                                );
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
                  ),
                  Button.grayText(
                    text: isEditing ? 'Ocultar' : 'Editar',
                    isActive: true,
                    rightIcon: isEditing ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
                    onPressed: () {
                      setState(() {
                        isEditing = !isEditing;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: _animationDuration,
            height: isEditing ? _addressContainerHeight : 0,
            curve: Curves.easeInOut,
            child: SingleChildScrollView(
              child: AnimatedOpacity(
                duration: _animationDuration,
                opacity: isEditing ? 1.0 : 0.0,
                child: Column(
                  children: [
                    LivitSpaces.s,
                    addressContainer(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCaptionCharCount() {
    int charCount = widget.location.description?.length ?? 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LivitSpaces.s,
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            LivitText('$charCount/50 caracteres', textType: LivitTextType.regular, color: LivitColors.whiteInactive),
          ],
        ),
      ],
    );
  }
}
