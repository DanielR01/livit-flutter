import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
import 'package:livit/models/location/product/location_product.dart';
import 'package:livit/models/media/location_media_file.dart';
import 'package:livit/services/firestore_storage/bloc/event/event_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/event/event_event.dart';
import 'package:livit/services/firestore_storage/bloc/event/event_state.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_event.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_state.dart';
import 'package:livit/services/firestore_storage/bloc/product/product_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/scanner/scanner_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/schedule/schedule_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/ticket/ticket_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/ticket/ticket_event.dart';
import 'package:livit/services/firestore_storage/bloc/ticket/ticket_state.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/bars_containers_fields/preview_field/preview_field.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/dialogs/livit_date_picker.dart';
import 'package:livit/utilities/display/livit_display_area.dart';
import 'package:livit/utilities/refresh_indicator.dart';
import 'package:livit/views/main_pages/promoters/location_detail/scanner/location_scanners_preview.dart';
import 'package:shimmer/shimmer.dart';

part 'ticket/tickets_count_bar.dart';
part 'location_selector_bar.dart';
part 'location_description.dart';
part 'media/location_media_preview.dart';
part 'location_location_preview.dart';
part 'event/next_event_snippet.dart';
part 'product/promoter_location_products_preview.dart';

class LocationDetailView extends StatefulWidget {
  const LocationDetailView({super.key});

  @override
  State<LocationDetailView> createState() => _LocationDetailViewState();
}

class _LocationDetailViewState extends State<LocationDetailView> {
  LivitLocation? _location;

  late final LocationBloc _locationBloc;
  late final TicketBloc _ticketBloc;
  late final EventsBloc _eventsBloc;
  late final ProductBloc _productBloc;

  @override
  void initState() {
    super.initState();
    _locationBloc = BlocProvider.of<LocationBloc>(context);
    _ticketBloc = BlocProvider.of<TicketBloc>(context);
    _eventsBloc = BlocProvider.of<EventsBloc>(context);
    _productBloc = BlocProvider.of<ProductBloc>(context);
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
              isLoading = state.loadingStates['cloud'] == LoadingState.loading;
            } else if (state is LocationUninitialized) {
              BlocProvider.of<LocationBloc>(context).add(InitializeLocationBloc(context));
            }
            if (!isLoading) {
              _location = _locationBloc.currentLocation;
              if (_location != null &&
                  (_eventsBloc.state is EventsLoaded &&
                      (_eventsBloc.state as EventsLoaded).loadedEvents[EventViewType.location]![_location!.id] == null)) {
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
                    Padding(
                      padding: LivitContainerStyle.horizontalPaddingFromScreen,
                      child: LivitBar.touchable(
                        shadowType: ShadowType.weak,
                        onTap: () {},
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
                    child: LocationSelectorBar(),
                  ),
                  //LivitSpaces.xs,
                  Expanded(
                    child: LivitRefreshIndicator(
                      onRefresh: () async {
                        BlocProvider.of<LocationBloc>(context).add(GetUserLocations(context));
                        if (_location != null) {
                          _locationBloc.add(GetUserLocations(context));
                          _eventsBloc.add(RefreshEvents());
                          _eventsBloc.add(FetchNextEventsByLocation(locationId: _location!.id));
                          _ticketBloc.add(RefreshTicketsCountByDate());
                          _productBloc.add(LoadLocationProducts(locationId: _location!.id));
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
                              TicketsCountBar(),
                              LivitSpaces.xs,
                              LocationDescription(description: _location!.description),
                              LivitSpaces.xs,
                              NextEventSnippet(locationId: _location!.id),
                              LivitSpaces.xs,
                              LocationMediaPreview(),
                              LivitSpaces.xs,
                              PromoterLocationProductsPreview(),
                              LivitSpaces.xs,
                              LocationLocationPreview(),
                              LivitSpaces.xs,
                              LocationScannersPreview(),
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
}
