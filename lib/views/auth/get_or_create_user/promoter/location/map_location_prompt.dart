import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/cloud_models/location.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/services/cloud/bloc/users/user_bloc.dart';
import 'package:livit/services/cloud/bloc/users/user_event.dart';
import 'package:livit/services/cloud/bloc/users/user_state.dart';
import 'package:livit/services/cloud/cloud_storage_exceptions.dart';
import 'package:livit/services/location/location_search_service.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/livit_scrollbar.dart';
import 'package:livit/utilities/map_viewer.dart';

class MapLocationPrompt extends StatefulWidget {
  final List<Location> locations;
  const MapLocationPrompt({super.key, required this.locations});

  @override
  State<MapLocationPrompt> createState() => _MapLocationPromptState();
}

class _MapLocationPromptState extends State<MapLocationPrompt> {
  final Map<String, double?> _coordinates = {
    'latitude': null,
    'longitude': null,
  };

  List<Location> _locations = [];

  bool _shouldUpdate = true;
  bool _shouldRemoveAnnotation = false;
  bool _shouldReinitialize = false;
  bool _shouldUseUserLocation = false;

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(keepPage: false, viewportFraction: 0.85);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCoordinates(widget.locations.first);
    });
    _locations = widget.locations;
  }

  @override
  void dispose() {
    // _pageController.dispose();
    super.dispose();
  }

  Future<void> _getCoordinates(Location location) async {
    try {
      final fullAddress = '${location.address}, ${location.city}, ${location.department}';
      final coordinates = await LocationSearchService.searchLocation(fullAddress);

      setState(() {
        _coordinates['latitude'] = coordinates['latitude']!;
        _coordinates['longitude'] = coordinates['longitude']!;
        _shouldUpdate = true;
        _shouldUseUserLocation = false;
      });
    } catch (e) {
      try {
        final cityAddress = '${location.city}, ${location.department}, Colombia';
        final cityCoordinates = await LocationSearchService.searchLocation(cityAddress);

        setState(() {
          _coordinates['latitude'] = cityCoordinates['latitude']!;
          _coordinates['longitude'] = cityCoordinates['longitude']!;
          _shouldUpdate = true;
          _shouldUseUserLocation = false;
        });
      } catch (e) {
        setState(() {
          _coordinates['latitude'] = 0;
          _coordinates['longitude'] = 0;
          _shouldUpdate = true;
          _shouldUseUserLocation = true;
        });
      }
    }
  }

  int _index = 0;

  Future<void> _showLocationsDialog(BuildContext context) async {
    bool interacted = false;

    await showDialog(
      context: context,
      barrierDismissible: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return PopScope(
          canPop: true,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: LivitColors.mainBlack,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: LivitContainerStyle.padding(),
                    child: LivitText(
                      'Tus ubicaciones',
                      textType: LivitTextType.smallTitle,
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    child: LivitScrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: LivitContainerStyle.padding(padding: null),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: _locations.asMap().entries.map((entry) {
                              final index = entry.key;
                              final location = entry.value;
                              final isSelected = index == _index;
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      interacted = true;
                                      if (index == _index) {
                                        setState(() {
                                          _shouldUpdate = true;
                                          _shouldReinitialize = true;
                                        });
                                        Navigator.of(context).pop();
                                      } else {
                                        setState(() {
                                          _index = index;
                                          _shouldReinitialize = true;
                                          _shouldUpdate = true;
                                        });
                                        Navigator.of(context).pop();
                                        _pageController.animateToPage(
                                          index,
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        Future.delayed(const Duration(milliseconds: 500), () {
                                          _getCoordinates(_locations[index]);
                                        });
                                      });
                                    },
                                    child: LivitBar(
                                      shadowType: isSelected ? ShadowType.strong : ShadowType.none,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Positioned(
                                            left: 0,
                                            child: Icon(
                                              Icons.circle,
                                              color: _locations[index].geopoint != null ? LivitColors.mainBlueActive : LivitColors.red,
                                              size: 6.sp,
                                            ),
                                          ),
                                          Padding(
                                            padding: LivitContainerStyle.padding(padding: [0, null, 0, null]),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                LivitText(
                                                  location.name,
                                                  textType: LivitTextType.smallTitle,
                                                ),
                                                LivitSpaces.xs,
                                                LivitText(
                                                  location.address,
                                                  color: LivitColors.whiteInactive,
                                                ),
                                                LivitText(
                                                  '${location.city}, ${location.department}',
                                                  color: LivitColors.whiteInactive,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (index != _locations.length - 1) LivitSpaces.s,
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Button.main(
                      text: 'Cerrar',
                      onPressed: () => Navigator.of(context).pop(),
                      isActive: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (mounted && !interacted) {
      setState(() {
        _shouldUpdate = true;
        _shouldReinitialize = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _getCoordinates(_locations[_index]);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String? errorMessage;
    bool _isLoading = false;
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is CurrentUser) {
          if (state.exception is CouldNotUpdateUserException) {
            errorMessage = 'No se pudo actualizar las ubicaciones, verifica tu conexión e intenta nuevamente mas tarde';
          } else if (state.exception == null) {
            errorMessage = null;
          }
          if (state.isLoading) {
            _isLoading = true;
          } else {
            _isLoading = false;
          }
        }
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: LivitContainerStyle.paddingFromScreen,
                child: GlassContainer(
                  titleBarText: _locations.length == 1 ? 'Selecciona tu ubicación' : 'Selecciona tus ubicaciones',
                  hasPadding: false,
                  child: Flexible(
                    child: Padding(
                        padding: LivitContainerStyle.padding(padding: [0, null, null, null]),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            LivitText(
                              _locations.length == 1
                                  ? 'Selecciona tu ubicación dejando presionado en el mapa. Intenta ser lo más preciso posible, esta ubicación la usaran tus clientes para encontrar tu local.'
                                  : 'Selecciona tus ubicaciones dejando presionado en el mapa. Intenta ser lo más preciso posible, estas ubicaciones las usaran tus clientes para encontrar tus locales.',
                              textType: LivitTextType.small,
                            ),
                            LivitSpaces.m,
                            SizedBox(
                              height: LivitBarStyle.height,
                              child: PageView.builder(
                                clipBehavior: Clip.none,
                                itemCount: _locations.length,
                                controller: _pageController,
                                //controller: PageController(viewportFraction: 0.85),
                                onPageChanged: (index) async {
                                  if (index == _index) return;
                                  setState(() {
                                    _index = index;
                                    _coordinates['latitude'] = null;
                                    _coordinates['longitude'] = null;
                                  });
                                  await _getCoordinates(_locations[index]);
                                },
                                itemBuilder: (context, index) {
                                  return AnimatedPadding(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.fastOutSlowIn,
                                    padding: EdgeInsets.symmetric(
                                        vertical: _index == index ? 0.0 : LivitContainerStyle.verticalPadding / 2,
                                        horizontal: LivitContainerStyle.horizontalPadding / 2),
                                    child: LivitBar(
                                      noPadding: true,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: LivitContainerStyle.horizontalPadding),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Positioned(
                                              left: 0,
                                              child: (_coordinates['latitude'] == null &&
                                                      _coordinates['longitude'] == null &&
                                                      _index == index)
                                                  ? SizedBox(
                                                      width: 8.sp,
                                                      height: 8.sp,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2.sp,
                                                        color: LivitColors.whiteActive,
                                                      ),
                                                    )
                                                  : Icon(
                                                      Icons.circle,
                                                      color:
                                                          _locations[index].geopoint != null ? LivitColors.mainBlueActive : LivitColors.red,
                                                      size: 6.sp,
                                                    ),
                                            ),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                LivitText(
                                                  _locations[index].name,
                                                  textType: LivitTextType.smallTitle,
                                                ),
                                                LivitText(
                                                  _locations[index].address,
                                                  textType: LivitTextType.small,
                                                  color: LivitColors.whiteInactive,
                                                ),
                                              ],
                                            ),
                                            if (_locations[index].geopoint != null)
                                              Positioned(
                                                right: 0,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _locations[index] = Location(
                                                        name: _locations[index].name,
                                                        address: _locations[index].address,
                                                        geopoint: null,
                                                        department: _locations[index].department,
                                                        city: _locations[index].city,
                                                      );
                                                      _shouldRemoveAnnotation = true;
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
                                                          CupertinoIcons.map_pin_slash,
                                                          color: LivitColors.whiteActive,
                                                          size: 16.sp,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            if (_locations.length > 1) ...[
                              LivitSpaces.xs,
                              Button.grayText(
                                isActive: true,
                                text: 'Ver todas las ubicaciones',
                                onPressed: () async {
                                  _showLocationsDialog(context);
                                },
                              ),
                            ],
                            LivitSpaces.xs,
                            Flexible(
                              child: Container(
                                clipBehavior: Clip.hardEdge,
                                decoration: LivitContainerStyle.decoration,
                                child: LivitMapView(
                                  shouldUpdate: _shouldUpdate,
                                  shouldReinitialize: _shouldReinitialize,
                                  shouldRemoveAnnotation: _shouldRemoveAnnotation,
                                  hoverCoordinates: _coordinates,
                                  locationCoordinates: _locations[_index].geopoint,
                                  shouldUseUserLocation: _shouldUseUserLocation,
                                  onUpdate: () {
                                    setState(() {
                                      _shouldUpdate = false;
                                      _shouldReinitialize = false;
                                      _shouldRemoveAnnotation = false;
                                    });
                                  },
                                  onLocationSelected: (location) {
                                    setState(
                                      () {
                                        _locations[_index] = _locations[_index].copyWith(
                                          geopoint: GeoPoint(location['latitude'], location['longitude']),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                            LivitSpaces.m,
                            Button.main(
                              text: _isLoading ? 'Continuando' : 'Continuar',
                              isLoading: _isLoading,
                              isActive: _locations.every((location) => location.geopoint != null),
                              onPressed: () {
                                BlocProvider.of<UserBloc>(context).add(SetPromoterUserLocations(locations: _locations));
                              },
                            ),
                          ],
                        )),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
