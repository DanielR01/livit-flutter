import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/constants/styles/shadows.dart';
import 'package:livit/models/event/event.dart';
import 'package:livit/models/location/location.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/models/media/location_media_file.dart';
import 'package:livit/services/firestore_storage/bloc/event/event_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/event/event_event.dart';
import 'package:livit/services/firestore_storage/bloc/event/event_state.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_event.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_state.dart';
import 'package:livit/services/firestore_storage/bloc/ticket/ticket_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/ticket/ticket_event.dart';
import 'package:livit/services/firestore_storage/bloc/ticket/ticket_state.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/dialogs/livit_date_picker.dart';
import 'package:livit/utilities/display/livit_display_area.dart';
import 'package:livit/utilities/events/event_preview.dart';
import 'package:livit/utilities/refresh_indicator.dart';

class LocationDetailView extends StatefulWidget {
  const LocationDetailView({super.key});

  @override
  State<LocationDetailView> createState() => _LocationDetailViewState();
}

class _LocationDetailViewState extends State<LocationDetailView> {
  LivitLocation? _location;
  List<LivitLocation>? _locations;

  late final LocationBloc _locationBloc;
  late final TicketBloc _ticketBloc;
  late final EventsBloc _eventsBloc;

  List<DateTime>? _selectedDateRange;
  bool _isLocationSelectorExpanded = false;

  bool _isMediaPreviewSelectorExpanded = false;

  @override
  void initState() {
    super.initState();
    _locationBloc = BlocProvider.of<LocationBloc>(context);
    _ticketBloc = BlocProvider.of<TicketBloc>(context);
    _eventsBloc = BlocProvider.of<EventsBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🛠️ [LocationDetailView] Building');
    return Scaffold(
      body: LivitDisplayArea(
        addHorizontalPadding: false,
        child: BlocBuilder<LocationBloc, LocationState>(
          builder: (context, state) {
            bool isLoading = true;
            if (state is LocationsLoaded) {
              _locations = state.cloudLocations;
              isLoading = state.loadingStates['cloud'] == LoadingState.loading;
            } else if (state is LocationUninitialized) {
              BlocProvider.of<LocationBloc>(context).add(InitializeLocationBloc(context));
            }
            if (!isLoading) {
              _location = _locationBloc.currentLocation;
              if (_location != null &&
                      (_eventsBloc.state is EventsLoaded &&
                          (_eventsBloc.state as EventsLoaded).loadedEvents[EventViewType.location]![_location!.id] == null) ||
                  (_eventsBloc.state is EventsInitial)) {
                debugPrint('📥 [LocationDetailView] Fetching next events for location ${_location!.id}');
                _eventsBloc.add(FetchNextEventsByLocation(locationId: _location!.id));
              }
            }
            if (_location == null) {
              debugPrint('✅ [LocationDetailView] Returning empty location detail view');
              return LivitRefreshIndicator(
                onRefresh: () async {
                  BlocProvider.of<LocationBloc>(context).add(GetUserLocations(context));
                },
                child: Column(
                  children: [
                    LivitBar(
                      shadowType: ShadowType.strong,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LivitText(
                            isLoading ? 'Cargando' : 'Crear una ubicación',
                            textType: LivitTextType.smallTitle,
                          ),
                          LivitSpaces.s,
                          if (!isLoading)
                            Icon(
                              CupertinoIcons.add_circled,
                              size: LivitButtonStyle.bigIconSize,
                              color: LivitColors.whiteActive,
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isLoading) ...[
                            CupertinoActivityIndicator(
                              radius: LivitButtonStyle.iconSize,
                              color: LivitColors.whiteActive,
                            ),
                            LivitSpaces.s,
                          ],
                          LivitText(
                            isLoading ? 'Obteniendo ubicaciones' : 'Aún no tienes ninguna ubicación. Crea una para empezar a promocionarla',
                            textType: LivitTextType.normalTitle,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              debugPrint('✅ [LocationDetailView] Returning location detail view');
              return Column(
                children: [
                  Padding(
                    padding: LivitContainerStyle.horizontalPaddingFromScreen,
                    child: _locationSelectorBar(),
                  ),
                  //LivitSpaces.xs,
                  Expanded(
                    child: LivitRefreshIndicator(
                      onRefresh: () async {
                        BlocProvider.of<LocationBloc>(context).add(GetUserLocations(context));
                        if (_location != null) {
                          _eventsBloc.add(RefreshEvents());
                          _eventsBloc.add(FetchNextEventsByLocation(locationId: _location!.id));
                          _ticketBloc.add(FetchTicketsCountByDate(
                            startDate: Timestamp.fromDate(
                                _selectedDateRange?[0] ?? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)),
                            endDate: Timestamp.fromDate(
                                _selectedDateRange?[1] ?? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1)),
                          ));
                        }
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: LivitContainerStyle.horizontalPaddingFromScreen.left,
                            vertical: LivitSpaces.xsDouble,
                          ),
                          child: Column(
                            children: [
                              _locationTicketsCounterBar(),
                              LivitSpaces.xs,
                              _nextEventSnippet(),
                              LivitSpaces.xs,
                              _locationMediaPreview(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _locationSelectorBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _isLocationSelectorExpanded ? (_locations?.length ?? 0) * LivitBarStyle.height + LivitBarStyle.height : LivitBarStyle.height,
      child: LivitBar(
        shadowType: ShadowType.weak,
        noPadding: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current/Selected Location Bar
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
                        ..._locations?.map(
                              (location) => _location == location
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
                                              color: location == _location ? LivitColors.whiteActive : LivitColors.whiteInactive,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ) ??
                            [],
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
  }

  Widget _locationTicketsCounterBar() {
    return BlocBuilder<TicketBloc, TicketState>(
      builder: (context, state) {
        late int? ticketsCount;
        late bool isError;
        if (state is TicketCountLoaded && state.loadingStates[_locationBloc.currentLocation!.id] == LoadingState.loading) {
          ticketsCount = null;
          isError = false;
        } else if (state is TicketCountLoaded && state.loadingStates[_locationBloc.currentLocation!.id] == LoadingState.loaded) {
          ticketsCount = state.ticketCounts[_locationBloc.currentLocation!.id];
          isError = false;
        } else if (state is TicketInitial ||
            (state is TicketCountLoaded && !state.loadingStates.containsKey(_locationBloc.currentLocation!.id))) {
          ticketsCount = null;
          isError = false;
          _ticketBloc.add(FetchTicketsCountByDate(
            startDate: Timestamp.fromDate(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)),
            endDate: Timestamp.fromDate(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1)),
          ));
        } else {
          ticketsCount = null;
          isError = true;
        }
        return LivitBar(
          shadowType: ShadowType.weak,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isError) ...[
                        LivitText('Error al cargar tickets', color: LivitColors.whiteInactive),
                        LivitSpaces.xs,
                        Icon(
                          CupertinoIcons.exclamationmark_circle,
                          size: LivitButtonStyle.iconSize,
                          color: LivitColors.whiteInactive,
                        )
                      ] else
                        Icon(
                          CupertinoIcons.tickets,
                          size: LivitButtonStyle.iconSize,
                          color: LivitColors.whiteActive,
                        ),
                      LivitSpaces.xs,
                      LivitText('Tickets vendidos: ', textType: LivitTextType.regular),
                      if (ticketsCount != null) ...[
                        LivitText('$ticketsCount', textType: LivitTextType.regular),
                      ] else
                        CupertinoActivityIndicator(
                          radius: LivitButtonStyle.iconSize / 2,
                          color: LivitColors.whiteActive,
                        ),
                    ],
                  ),
                  LivitSpaces.s,
                  Flexible(
                    child: LivitDatePicker(
                      onSelected: (date) {
                        debugPrint('🛠️ [LocationDetailView] Date selected: $date');
                        if (date == null) return;
                        setState(() {
                          _selectedDateRange = date;
                        });
                        if (_selectedDateRange!.length == 1) {
                          _ticketBloc.add(FetchTicketsCountByDate(
                            startDate: Timestamp.fromDate(_selectedDateRange![0]),
                            endDate: Timestamp.fromDate(_selectedDateRange![0]),
                          ));
                        } else {
                          _ticketBloc.add(FetchTicketsCountByDate(
                            startDate: Timestamp.fromDate(_selectedDateRange![0]),
                            endDate: Timestamp.fromDate(_selectedDateRange![1]),
                          ));
                        }
                      },
                      defaultDate: DateTime.now(),
                      isActive: true,
                      selectedDateRange: _selectedDateRange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _nextEventSnippet() {
    return BlocBuilder<EventsBloc, EventsState>(
      builder: (context, state) {
        debugPrint('🛠️ [LocationDetailView] Building next event snippet, state: $state');
        final bool isLoading = state is EventsLoaded && state.loadingStates[_locationBloc.currentLocation!.id] == LoadingState.loading;
        final List<LivitEvent> events =
            state is EventsLoaded ? state.loadedEvents[EventViewType.location]![_locationBloc.currentLocation!.id] ?? [] : [];
        final LivitEvent? nextEvent = events.isNotEmpty ? events.first : null;
        return LivitBar(
          noPadding: true,
          shadowType: ShadowType.weak,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LivitBar(
                shadowType: ShadowType.weak,
                child: LivitText('Próximo evento', textType: LivitTextType.smallTitle),
              ),
              if (isLoading)
                Padding(
                  padding: LivitContainerStyle.padding(),
                  child: EventPreview.loading(type: EventPreviewType.promoter),
                )
              else if (nextEvent != null)
                Padding(
                  padding: LivitContainerStyle.padding(),
                  child: EventPreview(event: nextEvent, type: EventPreviewType.promoter),
                )
              else
                Padding(
                  padding: LivitContainerStyle.padding(),
                  child: Column(
                    children: [
                      LivitText(
                        'No tienes próximos eventos.',
                        textType: LivitTextType.regular,
                      ),
                      LivitSpaces.s,
                      Button.main(
                        isActive: true,
                        text: 'Crea o programa nuevos eventos',
                        onTap: () {},
                        rightIcon: CupertinoIcons.calendar_badge_plus,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _locationMediaPreview() {
    final screenWidth = MediaQuery.of(context).size.width;
    final remainingWidth = screenWidth -
        LivitContainerStyle.paddingFromScreen.horizontal -
        LivitContainerStyle.horizontalPadding * 2 -
        LivitSpaces.sDouble * 3;
    final mediaDisplayWidth = remainingWidth / 4;
    final mediaDisplayHeight = mediaDisplayWidth * 16 / 9;
    final double mediaPreviewBarWidth =
        screenWidth - LivitContainerStyle.paddingFromScreen.horizontal - LivitContainerStyle.horizontalPadding * 2;
    final textPainter = TextPainter(
      text: TextSpan(text: 'Media', style: LivitTextStyle.smallTitleWhiteActiveText),
      textDirection: TextDirection.ltr,
    )..layout();
    final mediaPreviewBarTextWidth = textPainter.width;
    final mediaPreviewBarTextPosition = mediaPreviewBarWidth / 2 - mediaPreviewBarTextWidth / 2;

    return LivitBar(
      noPadding: true,
      shadowType: ShadowType.weak,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LivitBar.touchable(
            onTap: () {
              setState(() {
                _isMediaPreviewSelectorExpanded = !_isMediaPreviewSelectorExpanded;
              });
            },
            shadowType: ShadowType.weak,
            child: AnimatedContainer(
              duration: kThemeAnimationDuration,
              curve: Curves.easeInOut,
              height: LivitBarStyle.height,
              child: Padding(
                padding: LivitContainerStyle.padding(padding: [0, null, 0, null]),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    AnimatedPositioned(
                      duration: kThemeAnimationDuration,
                      curve: Curves.easeInOut,
                      left: _isMediaPreviewSelectorExpanded ? 0 : mediaPreviewBarTextPosition,
                      child: LivitText('Media', textType: LivitTextType.smallTitle),
                    ),
                    Positioned(
                      right: 0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedRotation(
                            duration: kThemeAnimationDuration,
                            turns: _isMediaPreviewSelectorExpanded ? 0 : 0.5,
                            child: Icon(
                              CupertinoIcons.chevron_right,
                              size: LivitButtonStyle.iconSize,
                              color: LivitColors.whiteActive,
                            ),
                          ),
                          AnimatedSize(
                            duration: kThemeAnimationDuration,
                            alignment: Alignment.center,
                            child: AnimatedOpacity(
                              duration: kThemeAnimationDuration,
                              opacity: _isMediaPreviewSelectorExpanded ? 1 : 0,
                              child: _isMediaPreviewSelectorExpanded
                                  ? Padding(
                                      padding: LivitContainerStyle.padding(padding: [0, 0, 0, LivitSpaces.xsDouble]),
                                      child: Wrap(
                                        spacing: LivitSpaces.sDouble,
                                        runSpacing: LivitSpaces.sDouble,
                                        children: [
                                          Button.secondary(
                                            boxShadow: [LivitShadows.inactiveWhiteShadow],
                                            leftIcon: CupertinoIcons.eye_fill,
                                            text: 'Ver como cliente',
                                            onTap: () {},
                                            isActive: true,
                                          ),
                                          Button.secondary(
                                            boxShadow: [LivitShadows.inactiveWhiteShadow],
                                            rightIcon: CupertinoIcons.pencil_circle,
                                            text: 'Editar',
                                            onTap: () {},
                                            isActive: true,
                                          ),
                                        ],
                                      ),
                                    )
                                  : SizedBox(height: LivitBarStyle.height, width: 0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          BlocBuilder<LocationBloc, LocationState>(
            builder: (context, state) {
              if (state is LocationsLoaded && state.loadingStates[_locationBloc.currentLocation!.id] == LoadingState.loading) {
                return _buildLoadingState();
              }

              final hasMedia = _locationBloc.currentLocation?.media?.files?.isNotEmpty ?? false;

              if (!hasMedia) {
                return _buildEmptyState();
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: LivitContainerStyle.padding(),
                  child: Row(
                    children: [
                      ..._locationBloc.currentLocation!.media!.files!.map(
                        (file) => GestureDetector(
                          onTap: () => _showMediaPreviewDialog(file),
                          child: Container(
                            width: mediaDisplayWidth,
                            height: mediaDisplayHeight,
                            decoration: LivitContainerStyle.decorationWithInactiveShadow,
                            clipBehavior: Clip.hardEdge,
                            child: _buildMediaPreview(file!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: LivitContainerStyle.padding(),
      child: CupertinoActivityIndicator(
        radius: LivitButtonStyle.iconSize / 2,
        color: LivitColors.whiteActive,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: LivitContainerStyle.padding(),
      child: Column(
        children: [
          LivitText(
            'No tienes ninguna imagen o video para mostrar.',
            textType: LivitTextType.regular,
          ),
          LivitSpaces.s,
          Button.main(
            isActive: true,
            text: 'Añade una imagen o video',
            onTap: () {},
            rightIcon: CupertinoIcons.photo_fill_on_rectangle_fill,
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPreview(LivitMediaFile file) {
    if (file is LivitMediaImage) {
      debugPrint('🛠️ [LocationDetailView] Building media preview for image: ${file.url}');
      return Image.network(
        (file.url ?? ''),
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CupertinoActivityIndicator(
              radius: LivitButtonStyle.iconSize / 2,
              color: LivitColors.whiteActive,
            ),
          );
        },
      );
    } else if (file is LivitMediaVideo) {
      debugPrint('🛠️ [LocationDetailView] Building media preview for video with cover: ${file.cover.url} and video: ${file.url}');
      return Stack(
        alignment: Alignment.center,
        children: [
          Image.network(
            file.cover.url ?? '',
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CupertinoActivityIndicator(
                  radius: LivitButtonStyle.iconSize / 2,
                  color: LivitColors.whiteActive,
                ),
              );
            },
          ),
          Icon(
            CupertinoIcons.play_circle_fill,
            color: LivitColors.whiteActive,
            size: LivitButtonStyle.bigIconSize,
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  void _showMediaPreviewDialog(LivitMediaFile file) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: LivitContainerStyle.decorationWithInactiveShadow,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (file is LivitMediaImage)
                Image.network(
                  file.url ?? '',
                  fit: BoxFit.contain,
                )
              else if (file is LivitMediaVideo)
                // Implement video player here
                Container(),
            ],
          ),
        ),
      ),
    );
  }
}
