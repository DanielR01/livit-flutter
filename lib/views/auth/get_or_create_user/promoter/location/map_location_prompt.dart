import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import 'package:livit/services/location/location_search_service.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/livit_scrollbar.dart';
import 'package:livit/utilities/map_prompt.dart';

class MapLocationPrompt extends StatefulWidget {
  const MapLocationPrompt({super.key});

  @override
  State<MapLocationPrompt> createState() => _MapLocationPromptState();
}

class _MapLocationPromptState extends State<MapLocationPrompt> {
  final Map<String, double?> _coordinates = {
    'latitude': null,
    'longitude': null,
  };
  bool _shouldZoomToUserLocation = false;

  List<LivitLocation> _locations = [];

  late final LocationBloc _locationBloc;

  bool _shouldUpdate = true;
  bool _shouldReinitialize = false;
  bool _shouldUseUserLocation = false;

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    debugPrint('🔄 [MapLocationPrompt] Initializing view...');
    _pageController = PageController(keepPage: false, viewportFraction: 0.85);
    _locationBloc = BlocProvider.of<LocationBloc>(context);
    _locations = _locationBloc.locations;
    debugPrint('📍 [MapLocationPrompt] Getting coordinates for first location: ${_locations.first.name}');
    _getCoordinates(_locations.first);
  }

  @override
  void dispose() {
    debugPrint('🚫 [MapLocationPrompt] Disposing view');
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _getCoordinates(LivitLocation location) async {
    if (!mounted) return;
    debugPrint('🔍 [MapLocationPrompt] Getting coordinates for location: ${location.name}');
    try {
      final fullAddress = '${location.address}, ${location.city}, ${location.state}';
      debugPrint('🔎 [MapLocationPrompt] Searching full address: $fullAddress');
      final coordinates = await LocationSearchService.searchLocation(fullAddress);

      if (!mounted) return;
      debugPrint('✅ [MapLocationPrompt] Found coordinates for full address');
      setState(() {
        _coordinates['latitude'] = coordinates['latitude']!;
        _coordinates['longitude'] = coordinates['longitude']!;
        _shouldUpdate = true;
        _shouldUseUserLocation = false;
        _shouldZoomToUserLocation = true;
      });
    } catch (e) {
      debugPrint('⚠️ [MapLocationPrompt] Failed to find full address, trying city only');
      try {
        final cityAddress = '${location.city}, ${location.state}, Colombia';
        debugPrint('🔎 [MapLocationPrompt] Searching city address: $cityAddress');
        final cityCoordinates = await LocationSearchService.searchLocation(cityAddress);

        if (!mounted) return;
        debugPrint('✅ [MapLocationPrompt] Found coordinates for city');
        setState(() {
          _coordinates['latitude'] = cityCoordinates['latitude']!;
          _coordinates['longitude'] = cityCoordinates['longitude']!;
          _shouldUpdate = true;
          _shouldUseUserLocation = false;
          _shouldZoomToUserLocation = false;
        });
      } catch (e) {
        debugPrint('❌ [MapLocationPrompt] Failed to find any coordinates, using default location');
        if (!mounted) return;
        setState(() {
          _coordinates['latitude'] = 0;
          _coordinates['longitude'] = 0;
          _shouldUpdate = true;
          _shouldUseUserLocation = true;
          _shouldZoomToUserLocation = false;
        });
      }
    }
  }

  int _index = 0;

  Future<void> _showLocationsDialog(BuildContext context) async {
    debugPrint('📋 [MapLocationPrompt] Showing locations dialog');
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
              decoration: LivitContainerStyle.decoration,
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
                                      debugPrint('🔍 [MapLocationPrompt] Tapping on location: ${location.name}');
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
                                        if (!mounted) return;
                                        Future.delayed(const Duration(milliseconds: 500), () {
                                          if (!mounted) return;
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
                                                  '${location.city}, ${location.state}',
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
                      onTap: () => Navigator.of(context).pop(),
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
      debugPrint('🔄 [MapLocationPrompt] Dialog closed without interaction, refreshing view');
      setState(() {
        _shouldUpdate = true;
        _shouldReinitialize = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          debugPrint('🔍 [MapLocationPrompt] Refreshing coordinates for current location');
          _getCoordinates(_locations[_index]);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🎨 [MapLocationPrompt] Building view with shouldZoomToUserLocation: $_shouldZoomToUserLocation');
    debugPrint('🎨 [MapLocationPrompt] Building view with coordinates: ${_coordinates['latitude']}, ${_coordinates['longitude']}');

    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        debugPrint('🎨 [MapLocationPrompt] Building view with state: ${state.runtimeType}');
        if (state is! LocationsLoaded) {
          debugPrint('❌ [MapLocationPrompt] Invalid state, showing error screen');
          throw Exception('Invalid state');
        }

        _locations = _locationBloc.locations;
        bool isCloudLoading = _locationBloc.isCloudLoading;

        String? errorMessage =
            state.errorMessage != null || state.failedLocations?.isNotEmpty == true ? 'Error actualizando tus ubicaciones' : null;

        if (errorMessage != null) {
          debugPrint('⚠️ [MapLocationPrompt] Error message: $errorMessage');
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
                              onPageChanged: (index) async {
                                debugPrint('🔍 [MapLocationPrompt] Page changed to index: $index');
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
                                      vertical: _index == index ? 0.0 : 0, horizontal: LivitContainerStyle.horizontalPadding / 2),
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
                                                    width: LivitButtonStyle.iconSize,
                                                    height: LivitButtonStyle.iconSize,
                                                    child: CupertinoActivityIndicator(
                                                      radius: LivitButtonStyle.iconSize / 2,
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
                                                  debugPrint(
                                                      '🔍 [MapLocationPrompt] Removing geopoint from location: ${_locations[index].name}');
                                                  BlocProvider.of<LocationBloc>(context).add(
                                                    UpdateLocationLocally(context, location: _locations[index].removeGeopoint()),
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
                              deactivateSplash: true,
                              text: 'Ver todas las ubicaciones',
                              onTap: () async {
                                _showLocationsDialog(context);
                              },
                            ),
                            LivitSpaces.xs,
                          ],
                          if (_locations.length == 1) LivitSpaces.m,
                          Flexible(
                            child: Container(
                              clipBehavior: Clip.hardEdge,
                              decoration: LivitContainerStyle.decoration,
                              child: LivitMapPrompt(
                                zoom: _shouldZoomToUserLocation ? 15.0 : 12.0,
                                shouldUpdate: _shouldUpdate,
                                shouldReinitialize: _shouldReinitialize,
                                shouldRemoveAnnotation: _locations[_index].geopoint == null,
                                hoverCoordinates: _coordinates,
                                locationCoordinates: _locations[_index].geopoint,
                                shouldUseUserLocation: _shouldUseUserLocation,
                                onUpdate: () {
                                  setState(() {
                                    _shouldUpdate = false;
                                    _shouldReinitialize = false;
                                  });
                                },
                                onLocationSelected: (location) {
                                  debugPrint('🔍 [MapLocationPrompt] Location selected: ${location['latitude']}, ${location['longitude']}');
                                  BlocProvider.of<LocationBloc>(context).add(
                                    UpdateLocationLocally(
                                      context,
                                      location: _locations[_index].copyWith(
                                        geopoint: GeoPoint(
                                          location['latitude'],
                                          location['longitude'],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          LivitSpaces.m,
                          if (errorMessage != null) ...[
                            LivitText(
                              errorMessage,
                              textType: LivitTextType.small,
                              fontWeight: FontWeight.bold,
                            ),
                            LivitSpaces.s,
                          ],
                          Button.main(
                            text: isCloudLoading ? 'Continuando' : 'Continuar',
                            isLoading: isCloudLoading,
                            isActive: _locations.every((location) => location.geopoint != null),
                            onTap: () {
                              debugPrint('🔍 [MapLocationPrompt] Updating locations to cloud');
                              BlocProvider.of<LocationBloc>(context).add(UpdateLocationsToCloudFromLocal(context));
                            },
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
      },
    );
  }
}
