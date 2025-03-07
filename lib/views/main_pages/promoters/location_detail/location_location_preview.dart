part of 'location_detail.dart';

class LocationLocationPreview extends StatefulWidget {
  const LocationLocationPreview({super.key});

  @override
  State<LocationLocationPreview> createState() => _LocationLocationPreviewState();
}

class _LocationLocationPreviewState extends State<LocationLocationPreview> {
  late GoogleMapController mapController;
  late final LocationBloc _locationBloc;
  late final ScheduleBloc _scheduleBloc;
  final String livitAppleMapViewer = "LivitAppleMapViewer";
  final Key _viewKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _locationBloc = BlocProvider.of<LocationBloc>(context);
    _scheduleBloc = BlocProvider.of<ScheduleBloc>(context);
    if (_scheduleBloc.state is ScheduleInitial ||
        (_scheduleBloc.state is ScheduleLoaded &&
            (_scheduleBloc.state as ScheduleLoaded).nextOpeningOrClosingDates[_locationBloc.currentLocation!.id] == null)) {
      _scheduleBloc.add(GetNextOpeningDateForPromoter(locationId: _locationBloc.currentLocation!.id, fromDate: DateTime.now()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      hasPadding: true,
      // shadowType: ShadowType.none,
      child: Column(
        children: [
          LivitBar.expandable(
            titleText: "Ubicación",
            buttons: [
              Button.secondary(
                boxShadow: [LivitShadows.inactiveWhiteShadow],
                isActive: true,
                text: "Modificar ubicación en el mapa",
                rightIcon: CupertinoIcons.map_pin_ellipse,
                onTap: () => {},
              ),
            ],
          ),
          _buildLocationInfo(),
          _buildMap(),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Padding(
      padding: LivitContainerStyle.padding(padding: [null, null, 0, null]),
      child: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, state) {
          if (state is! LocationsLoaded) {
            return Shimmer.fromColors(
              baseColor: LivitColors.whiteInactive,
              highlightColor: LivitColors.whiteActive,
              child: Container(
                height: 100,
              ),
            );
          } else {
            final location = _locationBloc.currentLocation;
            if (location != null) {
              _scheduleBloc.add(GetNextOpeningDateForPromoter(locationId: location.id, fromDate: DateTime.now()));
            }

            debugPrint('🏁 [LocationLocationPreview] Location: $location');
            if (location == null) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LivitText("Ocurrio un error al cargar la ubicación", textType: LivitTextType.regular),
                  LivitSpaces.xs,
                  Icon(
                    CupertinoIcons.exclamationmark_circle,
                    color: LivitColors.yellowError,
                    size: LivitButtonStyle.iconSize,
                  ),
                ],
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LivitBar.touchable(
                  shadowType: ShadowType.weak,
                  onTap: () => {},
                  child: Padding(
                    padding: LivitContainerStyle.padding(),
                    child: Row(
                      children: [
                        Icon(Icons.door_front_door_outlined, color: LivitColors.whiteActive, size: LivitButtonStyle.iconSize),
                        LivitSpaces.xs,
                        BlocBuilder<ScheduleBloc, ScheduleState>(
                          builder: (context, state) {
                            if (state is ScheduleInitial ||
                                (state is ScheduleLoaded &&
                                    (_scheduleBloc.state as ScheduleLoaded).loadingStates[location.id]?.nextOpeningDate ==
                                        LoadingState.loading)) {
                              return LivitText('Obteniendo horario...', textType: LivitTextType.regular);
                            }
                            if (state is ScheduleLoaded &&
                                (_scheduleBloc.state as ScheduleLoaded).nextOpeningOrClosingDates[location.id] != null &&
                                (_scheduleBloc.state as ScheduleLoaded).loadingStates[location.id]?.nextOpeningDate ==
                                    LoadingState.loaded) {
                              final ScheduleNextOpeningOrClosingDate nextOpeningOrClosingDate =
                                  (_scheduleBloc.state as ScheduleLoaded).nextOpeningOrClosingDates[location.id]!;
                              late final String text;
                              if (nextOpeningOrClosingDate.isOpening) {
                                if (nextOpeningOrClosingDate.date.day == DateTime.now().day) {
                                  text = 'Abre hoy a las ${_formatTime(nextOpeningOrClosingDate.date)}';
                                } else if (nextOpeningOrClosingDate.date.day == DateTime.now().day + 1) {
                                  text = 'Abre mañana a las ${_formatTime(nextOpeningOrClosingDate.date)}';
                                } else {
                                  text = 'Abre el ${nextOpeningOrClosingDate.date.day} a las ${_formatTime(nextOpeningOrClosingDate.date)}';
                                }
                              } else {
                                if (nextOpeningOrClosingDate.date.day == DateTime.now().day) {
                                  text = 'Cierra hoy a las ${_formatTime(nextOpeningOrClosingDate.date)}';
                                } else if (nextOpeningOrClosingDate.date.day == DateTime.now().day + 1) {
                                  text = 'Cierra mañana a las ${_formatTime(nextOpeningOrClosingDate.date)}';
                                } else {
                                  text =
                                      'Cierra el ${nextOpeningOrClosingDate.date.day} a las ${_formatTime(nextOpeningOrClosingDate.date)}';
                                }
                              }
                              return LivitText(text, textType: LivitTextType.regular);
                            }
                            if (state is ScheduleLoaded &&
                                (_scheduleBloc.state as ScheduleLoaded).loadingStates[location.id]?.nextOpeningDate == LoadingState.error) {
                              return Row(
                                children: [
                                  LivitText(
                                    'Ocurrio un error al obtener el horario',
                                    textType: LivitTextType.regular,
                                  ),
                                  LivitSpaces.xs,
                                  Icon(
                                    CupertinoIcons.exclamationmark_circle,
                                    color: LivitColors.yellowError,
                                    size: LivitButtonStyle.iconSize,
                                  ),
                                ],
                              );
                            } else if (state is ScheduleLoaded &&
                                (_scheduleBloc.state as ScheduleLoaded).nextOpeningOrClosingDates[location.id] == null &&
                                (_scheduleBloc.state as ScheduleLoaded).loadingStates[location.id]?.nextOpeningDate ==
                                    LoadingState.loaded) {
                              if (location.schedule == null) {
                                return Flexible(
                                    child: LivitText(
                                  'No se ha agregado un horario para este lugar',
                                  textType: LivitTextType.regular,
                                  textAlign: TextAlign.start,
                                ));
                              }
                              return Flexible(
                                  child: LivitText(
                                'No abre en los proximos 30 dias al momento',
                                textType: LivitTextType.regular,
                                textAlign: TextAlign.start,
                              ));
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                LivitSpaces.s,
                LivitBar(
                  shadowType: ShadowType.weak,
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.placemark, color: LivitColors.whiteActive, size: LivitButtonStyle.iconSize),
                      LivitSpaces.xs,
                      LivitText('${location.address}, ${location.city}, ${location.state}', textType: LivitTextType.regular),
                    ],
                  ),
                  // LivitSpaces.xs,
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildMap() {
    return Padding(
      padding: LivitContainerStyle.padding(),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          color: Colors.transparent,
          child: IgnorePointer(
            ignoring: true,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  decoration: LivitContainerStyle.decoration,
                  clipBehavior: Clip.hardEdge,
                  width: constraints.maxWidth,
                  height: constraints.maxWidth / 1.618,
                  child: BlocBuilder<LocationBloc, LocationState>(
                    builder: (context, state) {
                      if (state is! LocationsLoaded) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CupertinoActivityIndicator(
                              color: LivitColors.whiteActive,
                              radius: LivitButtonStyle.bigIconSize / 2,
                            ),
                            LivitSpaces.xs,
                            LivitText(
                              "Cargando ubicación...",
                              color: LivitColors.whiteInactive,
                              textType: LivitTextType.small,
                            ),
                          ],
                        );
                      }
                      final location = _locationBloc.currentLocation;
                      if (location == null) {
                        return const SizedBox.shrink();
                      }
                      final GeoPoint? locationCoordinates = location.geopoint;
                      if (locationCoordinates == null) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            LivitText(
                              "Aun no has agregado la ubicación en el mapa de tu lugar",
                              textType: LivitTextType.regular,
                            ),
                            LivitSpaces.s,
                            Button.main(
                              text: 'Marcar ubicación',
                              onTap: () {},
                              isActive: true,
                              rightIcon: CupertinoIcons.map_pin_ellipse,
                            ),
                          ],
                        );
                      }

                      if (Platform.isAndroid) {
                        debugPrint('🏁 [LocationLocationPreview] Building Android map');
                        return GoogleMap(
                            onMapCreated: _onMapCreated,
                            initialCameraPosition: CameraPosition(
                              target: LatLng(locationCoordinates.latitude, locationCoordinates.longitude),
                              zoom: 15,
                            ),
                            onLongPress: (LatLng point) {
                              debugPrint('🏁 [LocationLocationPreview] Long press at $point');
                            },
                            markers: {
                              Marker(
                                markerId: const MarkerId('location'),
                                position: LatLng(locationCoordinates.latitude, locationCoordinates.longitude),
                              ),
                            });
                      }
                      debugPrint('🏁 [LocationLocationPreview] Building iOS map');
                      return UiKitView(
                        key: _viewKey,
                        viewType: livitAppleMapViewer,
                        onPlatformViewCreated: (int id) {
                          MethodChannel('${livitAppleMapViewer}_$id').invokeMethod('setLocation', {
                            'latitude': locationCoordinates.latitude,
                            'longitude': locationCoordinates.longitude,
                            'title': location.name,
                          });
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  String _formatTime(DateTime date) {
    final hour = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
  }
}
