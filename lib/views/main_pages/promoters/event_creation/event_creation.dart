import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/models/event/event.dart';
import 'package:livit/models/event/event_media.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/bars_containers_fields/livit_text_field.dart';
import 'package:livit/utilities/buttons/arrow_back_button.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/display/livit_display_area.dart';
import 'package:livit/views/main_pages/promoters/event_creation/components/event_date_item.dart';
import 'package:livit/views/main_pages/promoters/event_creation/components/event_date_item_view.dart';
import 'package:livit/views/main_pages/promoters/event_creation/components/location_selection/location_selection.dart';
import 'package:livit/views/main_pages/promoters/event_creation/components/media/event_media_field.dart';
import 'package:livit/views/main_pages/promoters/event_creation/components/tickets_creation/tickets_creation.dart';

class EventCreationView extends StatefulWidget {
  const EventCreationView({super.key});

  @override
  State<EventCreationView> createState() => _EventCreationViewState();
}

class _EventCreationViewState extends State<EventCreationView> {
  // Keys to access child component states
  final GlobalKey<LocationSelectionState> _locationSelectionKey = GlobalKey<LocationSelectionState>();

  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _customLocationNameController = TextEditingController();

  // Event data
  final List<EventDateItem> _eventDates = [];
  LivitEvent _event = LivitEvent.empty();
  bool _isFormValid = false;

  bool _sameLocationForAllDates = true;

  @override
  void initState() {
    super.initState();
    _titleController.text = '';
    _descriptionController.text = '';
    _customLocationNameController.text = '';

    // Initialize with one default date
    _addEventDate();

    // Add listeners to update the event object
    _titleController.addListener(_updateEvent);
    _descriptionController.addListener(_updateEvent);
    _customLocationNameController.addListener(_updateEvent);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _customLocationNameController.dispose();

    // Dispose all date items
    for (var dateItem in _eventDates) {
      dateItem.dispose();
    }

    super.dispose();
  }

  void _addEventDate() {
    final dateIndex = _eventDates.length + 1;
    final name = 'Fecha $dateIndex';

    // Create default start/end times
    final now = DateTime.now();
    final startTime = DateTime(now.year, now.month, now.day + 7, 20, 0); // Next week at 8 PM
    final endTime = DateTime(now.year, now.month, now.day + 7, 23, 59); // Ends at midnight

    final dateItem = EventDateItem(
      initialName: name,
      startDate: startTime,
      endDate: endTime,
      onChanged: (eventDateItem) {
        setState(() {
          _updateEvent();
        });
      },
      onDelete: _removeEventDate,
    );

    setState(() {
      _eventDates.add(dateItem);
      _updateEvent();
    });
  }

  void _removeEventDate(String dateName) {
    setState(() {
      _eventDates.removeWhere((date) => date.name == dateName);
      _updateEvent();
    });
  }

  void _updateEvent() {
    debugPrint('Updating event');

    // Check the event description validity
    final String trimmedDescription = _descriptionController.text.trim();
    final bool isDescriptionValid = trimmedDescription.isNotEmpty && trimmedDescription.length <= 200;

    // Get event dates from the event date items
    final dates = _eventDates
        .map((dateItem) => EventDate(
              name: dateItem.name,
              startTime: Timestamp.fromDate(dateItem.startDate),
              endTime: Timestamp.fromDate(dateItem.endDate),
            ))
        .toList();

    // Get location data from the selection component
    final locationSelection = _locationSelectionKey.currentState;
    final List<EventLocation> locations = [];
    bool isLocationsValid = false;

    if (locationSelection != null) {
      // Get validation status to ensure data is valid
      final validation = locationSelection.validateAllLocations();
      isLocationsValid = validation['isValid'] as bool;

      if (isLocationsValid) {
        if (_sameLocationForAllDates) {
          // Single location for all dates
          final firstSelector = locationSelection.getFirstSelector();
          if (firstSelector != null) {
            final locationData = firstSelector.getLocationData();

            for (var date in dates) {
              locations.add(EventLocation(
                dateName: date.name,
                locationId: locationData['useExisting'] ? locationData['locationId'] : null,
                name: locationData['useExisting'] ? locationData['locationName'] : locationData['customName'],
                geopoint: locationData['geopoint'],
                address: locationData['address'],
                city: locationData['city'],
                state: locationData['state'],
                description: locationData['description'],
              ));
            }
          }
        } else {
          // Different location for each date
          final selectorsByDate = locationSelection.getAllSelectors();

          for (var date in dates) {
            final selector = selectorsByDate[date.name];
            if (selector != null) {
              final locationData = selector.getLocationData();

              locations.add(EventLocation(
                dateName: date.name,
                locationId: locationData['useExisting'] ? locationData['locationId'] : null,
                name: locationData['useExisting'] ? locationData['locationName'] : locationData['customName'],
                geopoint: locationData['geopoint'],
                address: locationData['address'],
                city: locationData['city'],
                state: locationData['state'],
                description: locationData['description'],
              ));
            }
          }
        }
      }
    }

    // Check the title validity
    final String trimmedTitle = _titleController.text.trim();
    final bool isTitleValid = trimmedTitle.isNotEmpty && trimmedTitle.length <= 100;

    // Ensure we have at least one event date
    final bool hasEventDates = _eventDates.isNotEmpty;

    // Update the form validity
    setState(() {
      _isFormValid = isTitleValid && isDescriptionValid && hasEventDates && isLocationsValid;

      // Update the event object
      _event = LivitEvent(
        id: _event.id,
        name: _titleController.text,
        description: _descriptionController.text,
        dates: dates,
        artists: [], // Will be added in another component
        locations: locations,
        media: EventMedia(media: []), // Will be added in another component
        promoters: [], // Will be populated on save
        eventTicketTypes: [], // Will be added in another component
        startTime: dates.isNotEmpty ? dates.first.startTime : Timestamp.now(),
        endTime: dates.isNotEmpty ? dates.last.endTime : Timestamp.now(),
      );
    });
  }

  void _selectMapLocation() {
    // This would show a map selection UI
    setState(() {
      _updateEvent();
    });
  }

  void _saveEvent() {
    // Save event logic here
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('event: $_event');
    return Scaffold(
      body: LivitDisplayArea(
        addHorizontalPadding: false,
        child: Column(
          children: [
            Padding(
              padding: LivitContainerStyle.horizontalPaddingFromScreen,
              child: LivitBar(
                noPadding: true,
                shadowType: ShadowType.weak,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ArrowBackButton(onPressed: () {
                      Navigator.pop(context);
                    }),
                    LivitText('Crear nuevo evento', textType: LivitTextType.smallTitle),
                    Opacity(
                      opacity: 0,
                      child: Button.icon(
                        icon: CupertinoIcons.checkmark_alt_circle,
                        onTap: () {},
                        isActive: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: LivitContainerStyle.paddingFromScreen,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTitleContainer(),
                      LivitSpaces.xs,
                      _buildDescriptionContainer(),
                      LivitSpaces.xs,
                      _buildEventDatesContainer(),
                      LivitSpaces.xs,
                      _buildLocationSelection(),
                      LivitSpaces.xs,
                      _buildMediaContainer(),
                      LivitSpaces.xs,
                      _buildTicketTypesContainer(),
                      LivitSpaces.xs,
                      _buildArtistsContainer(),
                      LivitSpaces.xs,
                      Button.main(
                        text: 'Crear evento',
                        onTap: _saveEvent,
                        isActive: _isFormValid,
                        rightIcon: CupertinoIcons.checkmark_alt_circle,
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

  Widget _buildTicketTypesContainer() {
    return GlassContainer(
      child: Column(
        children: [
          LivitBar(
            shadowType: ShadowType.weak,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [LivitText('Tiquetes', textType: LivitTextType.smallTitle)],
            ),
          ),
          Padding(
            padding: LivitContainerStyle.padding(),
            child: Column(
              children: [
                LivitText(
                  'Los tiquetes son la forma en la que tus clientes podrán acceder a tu evento. Puedes crear varios tipos, según el precio, fecha, hora de entrada, localidad y beneficios.\n Ademas, puedes definir la cantidad de tiquetes disponibles para cada tipo.',
                  color: LivitColors.whiteInactive,
                ),
                TicketsCreation(eventDates: _event.dates),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaContainer() {
    return GlassContainer(
      child: Column(
        children: [
          LivitBar(
            shadowType: ShadowType.weak,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [LivitText('Media', textType: LivitTextType.smallTitle)],
            ),
          ),
          Padding(
            padding: LivitContainerStyle.padding(),
            child: Column(
              children: [
                EventMediaField(initialMedia: _event.media.media),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistsContainer() {
    return GlassContainer(
      child: Column(
        children: [
          LivitBar(
            shadowType: ShadowType.weak,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.hammer,
                  color: LivitColors.whiteInactive,
                  size: LivitButtonStyle.iconSize,
                ),
                LivitSpaces.xs,
                LivitText('Artistas', textType: LivitTextType.smallTitle, color: LivitColors.whiteInactive),
              ],
            ),
          ),
          Padding(
            padding: LivitContainerStyle.padding(),
            child: Column(
              children: [
                LivitText(
                  'Pronto podras agregar artistas a tu evento, permitiendo que sus fans puedan encontrar tu evento.',
                  color: LivitColors.whiteInactive,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleContainer() {
    return GlassContainer(
      child: Column(
        children: [
          LivitBar(
            shadowType: ShadowType.weak,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [LivitText('Título del evento', textType: LivitTextType.smallTitle)],
            ),
          ),
          Padding(
            padding: LivitContainerStyle.padding(),
            child: LivitTextField(
              controller: _titleController,
              hint: 'Título del evento',
              externalIsValid: _titleController.text.trim().length <= 100 && _titleController.text.trim().isNotEmpty,
              bottomCaptionWidget: _buildTitleCharCount(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionContainer() {
    return GlassContainer(
      child: Column(
        children: [
          LivitBar(
            shadowType: ShadowType.weak,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [LivitText('Descripción del evento', textType: LivitTextType.smallTitle)],
            ),
          ),
          Padding(
            padding: LivitContainerStyle.padding(),
            child: Column(
              children: [
                LivitText('Agrega una descripción que ayude a tus clientes a entender el evento'),
                LivitSpaces.s,
                LivitTextField(
                  controller: _descriptionController,
                  hint: 'Descripción del evento',
                  isMultiline: true,
                  bottomCaptionWidget: _buildDescriptionCharCount(),
                  externalIsValid: _descriptionController.text.trim().length <= 200 && _descriptionController.text.trim().isNotEmpty,
                  onChanged: (value) {
                    _updateEvent();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDatesContainer() {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LivitBar(
            shadowType: ShadowType.weak,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LivitText(
                  'Fechas',
                  textType: LivitTextType.smallTitle,
                ),
              ],
            ),
          ),
          _buildEventDates(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: LivitContainerStyle.padding(),
                  child: Button.secondary(
                    text: 'Agregar fecha',
                    rightIcon: CupertinoIcons.calendar_badge_plus,
                    onTap: _addEventDate,
                    isActive: true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSelection() {
    return LocationSelection(
      key: _locationSelectionKey,
      eventDates: _event.dates,
      onUseExistingLocationChanged: (value) {
        setState(() {
          _updateEvent();
        });
      },
      onSelectedLocationChanged: (value) {
        setState(() {
          _updateEvent();
        });
      },
      onCustomLocationNameChanged: (value) {
        setState(() {
          _customLocationNameController.text = value;
          _updateEvent();
        });
      },
      onSelectMapLocation: _selectMapLocation,
      onSameLocationForAllDatesChanged: (value) {
        setState(() {
          _sameLocationForAllDates = value;
          _updateEvent();
        });
      },
      onValidationChanged: (isValid) {
        setState(() {
          // Update form validation state based on location validity
          _updateEvent();
        });
      },
    );
  }

  Widget _buildEventDates() {
    if (_eventDates.isEmpty) {
      return Padding(
        padding: LivitContainerStyle.padding(padding: [null, null, 0, null]),
        child: LivitBar(
          shadowType: ShadowType.weak,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.exclamationmark_triangle,
                color: LivitColors.yellowError,
                size: LivitButtonStyle.iconSize,
              ),
              LivitSpaces.xs,
              LivitText('Debes agregar al menos una fecha'),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _eventDates.map((dateItem) => EventDateItemView(dateItem: dateItem)).toList(),
    );
  }

  Widget _buildDescriptionCharCount() {
    int charCount = _descriptionController.text.trim().length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LivitSpaces.s,
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            LivitText('$charCount/200 caracteres',
                textType: LivitTextType.regular, color: charCount > 200 ? LivitColors.yellowError : LivitColors.whiteInactive),
          ],
        ),
      ],
    );
  }

  Widget _buildTitleCharCount() {
    int charCount = _titleController.text.trim().length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LivitSpaces.s,
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            LivitText('$charCount/100 caracteres',
                textType: LivitTextType.regular, color: charCount > 100 ? LivitColors.yellowError : LivitColors.whiteInactive),
          ],
        ),
      ],
    );
  }
}
