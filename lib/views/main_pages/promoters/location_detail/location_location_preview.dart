part of 'location_detail.dart';

class LocationLocationPreview extends StatefulWidget {
  const LocationLocationPreview({super.key});

  @override
  State<LocationLocationPreview> createState() => _LocationLocationPreviewState();
}

class _LocationLocationPreviewState extends State<LocationLocationPreview> {
  late GoogleMapController mapController;
  late final LocationBloc _locationBloc;

  final String livitAppleMapViewer = "LivitAppleMapViewer";
  final Key _viewKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _locationBloc = BlocProvider.of<LocationBloc>(context);
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
                text: "Editar dirección",
                rightIcon: CupertinoIcons.placemark,
                onTap: () => {},
              ),
              Button.secondary(
                boxShadow: [LivitShadows.inactiveWhiteShadow],
                isActive: true,
                text: "Modificar ubicación",
                rightIcon: CupertinoIcons.map_pin,
                onTap: () => {},
              ),
            ],
          ),
          _buildMap(),
        ],
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
                        return const SizedBox.shrink();
                      }
                      final location = _locationBloc.currentLocation;
                      if (location == null) {
                        return const SizedBox.shrink();
                      }
                      final GeoPoint? locationCoordinates = location.geopoint;
                      if (locationCoordinates == null) {
                        return const SizedBox.shrink();
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
}
