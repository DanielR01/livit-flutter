part of 'location_detail.dart';

class LocationSelectorBar extends StatefulWidget {
  const LocationSelectorBar({super.key});

  @override
  State<LocationSelectorBar> createState() => _LocationSelectorBarState();
}

class _LocationSelectorBarState extends State<LocationSelectorBar> {
  late final LocationBloc _locationBloc;
  late final List<LivitLocation> _locations;
  late LivitLocation? _location;
  bool _isLocationSelectorExpanded = false;

  @override
  void initState() {
    _locationBloc = BlocProvider.of<LocationBloc>(context);
    _locations = _locationBloc.locations;
    _location = _locationBloc.currentLocation;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        _location = _locationBloc.currentLocation;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _isLocationSelectorExpanded ? _locations.length * LivitBarStyle.height + LivitBarStyle.height : LivitBarStyle.height,
          child: LivitBar(
            shadowType: ShadowType.weak,
            noPadding: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                            overflow: TextOverflow.ellipsis,
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
                            ..._locations.map(
                              (location) => _location?.id == location.id
                                  ? const SizedBox.shrink()
                                  : LivitBar.touchable(
                                      shadowType: ShadowType.none,
                                      noPadding: true,
                                      onTap: () {
                                        setState(() {
                                          _locationBloc.add(SetCurrentLocation(context, locationId: location.id));
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
                                              color: location.id == _location?.id ? LivitColors.whiteActive : LivitColors.whiteInactive,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ),
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
      },
    );
  }
}
