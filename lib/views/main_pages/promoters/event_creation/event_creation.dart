import 'dart:io';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/models/event/event.dart';
import 'package:livit/models/event/event_media.dart';
import 'package:livit/models/media/livit_media_file.dart';
import 'package:livit/services/firestore_storage/bloc/event/event_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/event/event_event.dart';
import 'package:livit/services/firestore_storage/bloc/event/event_state.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/bars_containers_fields/livit_text_field.dart';
import 'package:livit/utilities/buttons/arrow_back_button.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/debug/livit_debugger.dart';
import 'package:livit/utilities/display/livit_display_area.dart';
import 'package:livit/views/main_pages/promoters/event_creation/components/event_date_item.dart';
import 'package:livit/views/main_pages/promoters/event_creation/components/event_date_item_view.dart';
import 'package:livit/views/main_pages/promoters/event_creation/components/location_selection/location_selection.dart';
import 'package:livit/views/main_pages/promoters/event_creation/components/media/event_media_field.dart';
import 'package:livit/views/main_pages/promoters/event_creation/components/tickets_creation/tickets_creation.dart';
import 'package:livit/views/main_pages/promoters/event_creation/dialogs/error_dialog.dart';
import 'package:livit/services/firestore_storage/bloc/user/user_bloc.dart';

part 'dialogs/success_dialog.dart';
part 'dialogs/loading_dialog.dart';
part 'dialogs/final_success_dialog.dart';

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
  bool _isSaving = false;

  bool _sameLocationForAllDates = true;

  // Add this field to track ticket types
  final List<EventTicketType> _ticketTypes = [];
  final List<LivitMediaFile> _media = [];

  final LivitDebugger _debugger = const LivitDebugger('event_creation', isDebugEnabled: true);

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
    _debugger.debPrint('Adding new event date', DebugMessageType.creating);
    final String uniqueName = _getUniqueDateName();
    final eventDate = EventDateItem(
      initialName: uniqueName,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(hours: 2)),
      onChanged: (updatedDate) {
        _updateEvent();
      },
      onDelete: (dateItem) {
        _removeEventDate(dateItem);
      },
    );

    setState(() {
      _eventDates.add(eventDate);
      _updateEvent();
    });
  }

  void _removeEventDate(EventDateItem dateItem) {
    _debugger.debPrint('Removing event date: ${dateItem.name}', DebugMessageType.deleting);
    final removedDateName = dateItem.name;

    setState(() {
      _eventDates.remove(dateItem);

      // Update ticket types that reference the removed date
      if (_eventDates.isNotEmpty) {
        final firstAvailableDateName = _eventDates[0].name;
        _debugger.debPrint('Checking tickets referencing removed date, will use: $firstAvailableDateName', DebugMessageType.info);

        for (int i = 0; i < _ticketTypes.length; i++) {
          if (_ticketTypes[i].validTimeSlots.any((timeSlot) => timeSlot.dateName == removedDateName)) {
            _debugger.debPrint('Updating ticket ${i + 1} to use date: $firstAvailableDateName', DebugMessageType.updating);
            // Update the ticket type to use the first available date
            _ticketTypes[i] = EventTicketType(
              name: _ticketTypes[i].name,
              totalQuantity: _ticketTypes[i].totalQuantity,
              validTimeSlots: [
                EventDateTimeSlot(
                    dateName: firstAvailableDateName,
                    startTime: Timestamp.fromDate(_eventDates[0].startDate),
                    endTime: Timestamp.fromDate(_eventDates[0].endDate))
              ],
              description: _ticketTypes[i].description,
              price: _ticketTypes[i].price,
            );
          }
        }
      } else {
        _debugger.debPrint('No dates left after removal', DebugMessageType.info);
      }
    });
    _updateEvent();
  }

  void _onMediaChanged(List<LivitMediaFile> updatedMedia) {
    _debugger.debPrint('Updating media, count: ${updatedMedia.length}', DebugMessageType.updating);
    _media.clear();
    _media.addAll(updatedMedia);
    _updateEvent();
  }

  void _onTicketsChanged(List<EventTicketType> updatedTickets) {
    _debugger.debPrint('Updating ticket types: $updatedTickets', DebugMessageType.updating);

    _ticketTypes.clear();
    _ticketTypes.addAll(updatedTickets);
    _updateEvent();
  }

  void _updateEvent() {
    _debugger.debPrint(
        '🔄 [event_creation] _updateEvent called - build phase: ${WidgetsBinding.instance.buildOwner?.debugBuilding ?? false}',
        DebugMessageType.info);

    // Check if we're in the build phase
    if (WidgetsBinding.instance.buildOwner?.debugBuilding ?? false) {
      _debugger.debPrint('WARNING: _updateEvent called during build phase!', DebugMessageType.warning);
      // Consider using a post-frame callback instead
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _debugger.debPrint('Deferred _updateEvent running after frame', DebugMessageType.info);
        _updateEventImpl();
      });
      return;
    }

    _updateEventImpl();
    _debugger.debPrint('🔄 [event_creation] _updateEvent finished', DebugMessageType.info);
    _debugger.debPrint('🔄 [event_creation] event: $_event', DebugMessageType.info);
  }

  // Separate implementation to avoid duplication
  void _updateEventImpl() {
    _debugger.debPrint('🔄 [event_creation] Updating event', DebugMessageType.info);
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

    // Update the form validity
    setState(() {
      // Update the event object
      _event = LivitEvent(
        id: _event.id,
        name: _titleController.text,
        description: _descriptionController.text,
        dates: dates,
        artists: [], // Will be added in another component
        locations: locations,
        media: EventMedia(media: _media),
        promoterIds: [], // Will be populated on save
        eventTicketTypes: _ticketTypes,
        startTime: dates.isNotEmpty ? dates.first.startTime : Timestamp.now(),
        endTime: dates.isNotEmpty ? dates.last.endTime : Timestamp.now(),
        createdAt: null,
        updatedAt: null,
      );
    });
  }

  void _selectMapLocation() {
    // This would show a map selection UI
    setState(() {
      _updateEvent();
    });
  }

  Future<void> _saveEvent() async {
    _debugger.debPrint('Saving event: $_event', DebugMessageType.saving);
    _debugger.debPrint('Checking initial event validity', DebugMessageType.verifying);
    final isValid = _checkInitialEventValidity();
    if (!isValid) {
      _debugger.debPrint('Event is not valid', DebugMessageType.error);
      return;
    }
    _debugger.debPrint('Event is initially valid', DebugMessageType.done);
    _debugger.debPrint('Performing full check', DebugMessageType.verifying);
    final fullIsValid = await _checkFullEventValidity();
    if (!fullIsValid['isValid']) {
      _debugger.debPrint('Event is not valid', DebugMessageType.error);
      if (mounted) {
        showErrorDialog(context, fullIsValid['error']);
      }
      return;
    }
    _debugger.debPrint('Event is valid', DebugMessageType.done);

    // Set loading state
    setState(() {
      _isSaving = true;
    });
    final BuildContext outerContext = context;
    // Show loading dialog
    if (mounted) {
      _showLoadingDialog(context);
    }

    try {
      _debugger.debPrint('Creating event through BLoC', DebugMessageType.creating);

      // Get BLoC instance from the context
      late final EventsBloc eventsBloc;
      if (mounted) {
        eventsBloc = BlocProvider.of<EventsBloc>(context);
      } else {
        return;
      }

      // Set up a listener for the BLoC states
      late final StreamSubscription<EventsState> subscription;

      subscription = eventsBloc.stream.listen(
        (state) {
          _debugger.debPrint('Received BLoC state: ${state.runtimeType}', DebugMessageType.info);

          if (state is EventCreated) {
            _debugger.debPrint('Event created successfully with ID: ${state.eventId}', DebugMessageType.done);

            if (mounted) {
              // Dismiss loading dialog if it's showing
              Navigator.of(context, rootNavigator: true).pop();

              // Upload media for the newly created event
              _uploadEventMedia(outerContext, state.eventId);
            }

            subscription.cancel();
          } else if (state is EventCreationError) {
            _debugger.debPrint('Error creating event: ${state.message}', DebugMessageType.error);

            if (mounted) {
              // Dismiss loading dialog if it's showing
              Navigator.of(context, rootNavigator: true).pop();

              // Show error message
              showErrorDialog(context, state.message, title: 'Error al crear evento');

              // Reset saving state
              setState(() {
                _isSaving = false;
              });
            }

            subscription.cancel();
          }
        },
        onError: (error) {
          _debugger.debPrint('Error in BLoC stream: $error', DebugMessageType.error);

          if (mounted) {
            // Dismiss loading dialog if it's showing
            Navigator.of(context, rootNavigator: true).pop();

            // Reset saving state
            setState(() {
              _isSaving = false;
            });

            // Show error message
            showErrorDialog(context, error.toString(), title: 'Error al crear evento');
          }

          subscription.cancel();
        },
      );

      // Dispatch the action to create the event
      eventsBloc.add(CreateEvent(event: _event));
    } catch (e) {
      _debugger.debPrint('Exception while interacting with BLoC: $e', DebugMessageType.error);

      if (mounted) {
        // Dismiss loading dialog if it's showing
        Navigator.of(context, rootNavigator: true).pop();

        // Reset saving state
        setState(() {
          _isSaving = false;
        });

        // Show error message
        showErrorDialog(context, 'Error al crear evento: ${e.toString()}');
      }
    }
  }

  Future<void> _uploadEventMedia(BuildContext outerContext, String eventId) async {
    _debugger.debPrint('Uploading media for event: $eventId', DebugMessageType.uploading);

    if (_event.media.media.isEmpty) {
      _debugger.debPrint('No media to upload', DebugMessageType.info);
      await _showFinalSuccessDialog(context, eventId);
      await Future.delayed(const Duration(milliseconds: 100));
      if (outerContext.mounted) {
        _debugger.debPrint('Navigating back to main view', DebugMessageType.info);
        Navigator.of(outerContext).popUntil((route) {
          return route.settings.name == Routes.mainViewRoute || route.isFirst;
        });
      }
      return;
    } else {
      _showSuccessDialog(context, eventId);
    }

    try {
      // Get the user bloc to get promoter ID
      final userBloc = BlocProvider.of<UserBloc>(context);
      final String promoterId = userBloc.currentUser?.id ?? '';

      // Create a copy of the event with the new ID and promoter ID
      final eventWithId = _event.copyWith(
        id: eventId,
        promoterIds: [promoterId],
      );

      _debugger.debPrint('Prepared event for media upload with ID: $eventId and promoter ID: $promoterId', DebugMessageType.info);

      // Get the events bloc
      final eventsBloc = BlocProvider.of<EventsBloc>(context);

      // Set up a listener for the BLoC states
      late final StreamSubscription<EventsState> subscription;

      subscription = eventsBloc.stream.listen(
        (state) async {
          _debugger.debPrint('Received BLoC state for media upload: ${state.runtimeType}', DebugMessageType.info);

          if (state is EventUpdated) {
            _debugger.debPrint('Media uploaded successfully for event ID: $eventId', DebugMessageType.done);

            if (mounted) {
              // Dismiss loading dialog if it's showing
              Navigator.of(context, rootNavigator: true).pop();

              // Show success dialog
              await _showFinalSuccessDialog(context, eventId);
              await Future.delayed(const Duration(milliseconds: 100));
              if (outerContext.mounted) {
                _debugger.debPrint('Navigating back to main view', DebugMessageType.info);
                Navigator.of(outerContext).popUntil((route) {
                  return route.settings.name == Routes.mainViewRoute || route.isFirst;
                });
              }
            }

            subscription.cancel();

            setState(() {
              _isSaving = false;
            });
          } else if (state is EventUpdateError) {
            _debugger.debPrint('Error uploading media: ${state.message}', DebugMessageType.error);

            if (mounted) {
              // Dismiss loading dialog if it's showing
              Navigator.of(context, rootNavigator: true).pop();

              // Show error message
              showErrorDialog(context, 'Los archivos multimedia no pudieron ser subidos: ${state.message}',
                  title: 'Error al subir archivos multimedia');

              if (outerContext.mounted) {
                _debugger.debPrint('Navigating back to main view', DebugMessageType.info);
                Navigator.of(outerContext).popUntil((route) {
                  return route.settings.name == Routes.mainViewRoute || route.isFirst;
                });
              }
            }

            subscription.cancel();

            setState(() {
              _isSaving = false;
            });
          }
        },
        onError: (error) {
          _debugger.debPrint('Error in BLoC stream during media upload: $error', DebugMessageType.error);

          if (mounted) {
            // Dismiss loading dialog if it's showing
            Navigator.of(context, rootNavigator: true).pop();

            // Show error message
            showErrorDialog(context, 'Error al subir archivos multimedia: ${error.toString()}', title: 'Error en el servidor');
            if (outerContext.mounted) {
              _debugger.debPrint('Navigating back to main view', DebugMessageType.info);
              Navigator.of(outerContext).popUntil((route) {
                return route.settings.name == Routes.mainViewRoute || route.isFirst;
              });
            }
          }

          subscription.cancel();

          setState(() {
            _isSaving = false;
          });
        },
      );

      // Dispatch the action to upload media
      eventsBloc.add(SetEventMedia(event: eventWithId, context: context));

      _debugger.debPrint('Media upload started for event: $eventId', DebugMessageType.info);
    } catch (e) {
      _debugger.debPrint('Error starting media upload: $e', DebugMessageType.error);

      setState(() {
        _isSaving = false;
      });

      if (mounted) {
        // Dismiss loading dialog if it's showing
        Navigator.of(context, rootNavigator: true).pop();

        showErrorDialog(context, 'Error al subir archivos multimedia: ${e.toString()}');
        if (outerContext.mounted) {
          _debugger.debPrint('Navigating back to main view', DebugMessageType.info);
          Navigator.of(outerContext).popUntil((route) {
            return route.settings.name == Routes.mainViewRoute || route.isFirst;
          });
        }
      }
    }
  }

  Future<Map<String, dynamic>> _checkFullEventValidity() async {
    _debugger.debPrint('Checking full event validity', DebugMessageType.verifying);
    for (var date in _event.dates) {
      if (date.startTime.toDate().isAfter(date.endTime.toDate())) {
        _debugger.debPrint('Date start time is after end time', DebugMessageType.error);
        return {'isValid': false, 'error': 'Date start time is after end time'};
      } else if (date.startTime.toDate().isBefore(DateTime.now())) {
        _debugger.debPrint('Date start time is before current date', DebugMessageType.error);
        return {'isValid': false, 'error': 'Date start time is before current date'};
      }
      if (!_event.locations.any((location) => location.dateName == date.name)) {
        _debugger.debPrint('No location found for date: $date', DebugMessageType.error);
        return {'isValid': false, 'error': 'No location found for date'};
      }
      if (!_event.eventTicketTypes.any((ticketType) => ticketType.validTimeSlots.any((timeSlot) => timeSlot.dateName == date.name))) {
        _debugger.debPrint('No ticket type found for date: $date', DebugMessageType.error);
        return {'isValid': false, 'error': 'No ticket type found for date'};
      }
    }

    for (var media in _event.media.media) {
      if (media.filePath == null) {
        _debugger.debPrint('Media file path is null', DebugMessageType.error);
        return {'isValid': false, 'error': 'Media file path is null'};
      }
      final file = File(media.filePath!);
      if (!file.existsSync()) {
        _debugger.debPrint('Media file does not exist', DebugMessageType.error);
        return {'isValid': false, 'error': 'Media file does not exist'};
      }
      final fileSize = await file.length();
      if (fileSize > 100 * 1024 * 1024) {
        // 100MB limit
        _debugger.debPrint('Media file is too large', DebugMessageType.error);
        return {'isValid': false, 'error': 'Media file is too large'};
      }
      if (media is LivitMediaVideo) {
        if (media.cover.filePath == null) {
          _debugger.debPrint('Video media cover file path is null', DebugMessageType.error);
          return {'isValid': false, 'error': 'Video media cover file path is null'};
        }
      }
    }

    if (_event.media.media.length > 7) {
      _debugger.debPrint('Event media count is greater than 7', DebugMessageType.error);
      return {'isValid': false, 'error': 'Event media count is greater than 7'};
    }

    if (_event.eventTicketTypes.any(
        (ticketType) => ticketType.validTimeSlots.any((timeSlot) => timeSlot.endTime.toDate().isBefore(timeSlot.startTime.toDate())))) {
      _debugger.debPrint('Ticket type valid time slots end time is before start time', DebugMessageType.error);
      return {'isValid': false, 'error': 'Ticket type valid time slots end time is before start time'};
    }

    if (_event.eventTicketTypes
        .any((ticketType) => ticketType.validTimeSlots.any((timeSlot) => timeSlot.startTime.toDate().isBefore(DateTime.now())))) {
      _debugger.debPrint('Ticket type valid time slots start time is before current date', DebugMessageType.error);
      return {'isValid': false, 'error': 'Ticket type valid time slots start time is before current date'};
    }

    if (_event.eventTicketTypes.any(
      (ticketType) => ticketType.validTimeSlots.any((timeSlot) {
        final date = _event.dates.firstWhere((date) => date.name == timeSlot.dateName);
        if (timeSlot.startTime.toDate().isAfter(date.startTime.toDate())) {
          return true;
        }
        return false;
      }),
    )) {
      _debugger.debPrint('Ticket type valid time slot start time is after date start time', DebugMessageType.error);
      return {'isValid': false, 'error': 'Ticket type valid time slot start time is after date start time'};
    }

    if (_event.eventTicketTypes.any(
      (ticketType) => ticketType.validTimeSlots.any((timeSlot) {
        final date = _event.dates.firstWhere((date) => date.name == timeSlot.dateName);
        if (timeSlot.endTime.toDate().isAfter(date.endTime.toDate())) {
          return true;
        }
        return false;
      }),
    )) {
      _debugger.debPrint('Ticket type valid time slot end time is after date end time', DebugMessageType.error);
      return {'isValid': false, 'error': 'Ticket type valid time slot end time is after date end time'};
    }

    return {'isValid': true};
  }

  bool _checkInitialEventValidity() {
    _debugger.debPrint('Checking initial event validity for $_event', DebugMessageType.info);

    final bool isNameValid = _event.name.trim().isNotEmpty && _event.name.trim().length <= 100;
    if (!isNameValid) {
      _debugger.debPrint('Event name is too long or empty', DebugMessageType.error);
      return false;
    }
    final bool isDescriptionValid = _event.description.trim().isNotEmpty && _event.description.trim().length <= 200;
    if (!isDescriptionValid) {
      _debugger.debPrint('Event description is too long or empty', DebugMessageType.error);
      return false;
    }
    final bool hasEventDates = _event.dates.isNotEmpty;
    if (!hasEventDates) {
      _debugger.debPrint('Event dates are empty', DebugMessageType.error);
      return false;
    }
    final bool hasLocations = _event.locations.isNotEmpty;
    if (!hasLocations) {
      _debugger.debPrint('Event locations are empty', DebugMessageType.error);
      return false;
    }
    final bool hasMedia = _event.media.media.isNotEmpty;
    if (!hasMedia) {
      _debugger.debPrint('Event media are empty', DebugMessageType.error);
      return false;
    }
    final bool hasTicketTypes = _event.eventTicketTypes.isNotEmpty;
    if (!hasTicketTypes) {
      _debugger.debPrint('Event ticket types are empty', DebugMessageType.error);
      return false;
    }
    final bool hasSameNumberOfDatesAndLocations = _event.dates.length == _event.locations.length;
    if (!hasSameNumberOfDatesAndLocations) {
      _debugger.debPrint('Event dates and locations have different lengths', DebugMessageType.error);
      return false;
    }

    for (var date in _event.dates) {
      if (date.name.length > 100 || date.name.trim().isEmpty) {
        _debugger.debPrint('Event date name is too long or empty', DebugMessageType.error);
        return false;
      }
    }

    for (var location in _event.locations) {
      if (location.locationId == null) {
        if (location.name == null || location.name!.trim().isEmpty || location.name!.trim().length > 100) {
          _debugger.debPrint('Location name is too long or null or empty', DebugMessageType.error);
          return false;
        }
        if (location.geopoint == null) {
          _debugger.debPrint('Location geopoint is null', DebugMessageType.error);
          return false;
        }
        if (location.address == null || (location.address?.length ?? 0) > 100) {
          _debugger.debPrint('Location address is too long or null', DebugMessageType.error);
          return false;
        }
        if (location.city == null || (location.city?.length ?? 0) > 100) {
          _debugger.debPrint('Location city is too long or null', DebugMessageType.error);
          return false;
        }
        if (location.state == null || (location.state?.length ?? 0) > 100) {
          _debugger.debPrint('Location state is too long or null', DebugMessageType.error);
          return false;
        }
      }
      if (location.description != null && (location.description?.length ?? 0) > 200) {
        _debugger.debPrint('Location description is too long', DebugMessageType.error);
        return false;
      }
    }

    for (var media in _event.media.media) {
      if (media is LivitMediaImage) {
        if (media.filePath == null) {
          _debugger.debPrint('Image media file path is null', DebugMessageType.error);
          return false;
        }
      } else if (media is LivitMediaVideo) {
        if (media.filePath == null) {
          _debugger.debPrint('Video media file path is null', DebugMessageType.error);
          return false;
        }
        if (media.cover.filePath == null) {
          _debugger.debPrint('Video media cover file path is null', DebugMessageType.error);
          return false;
        }
      }
    }

    for (var ticketType in _event.eventTicketTypes) {
      if (ticketType.name == null || ticketType.name!.trim().isEmpty || ticketType.name!.trim().length > 100) {
        _debugger.debPrint('Ticket type name is too long or null or empty', DebugMessageType.error);
        return false;
      }
      if (ticketType.totalQuantity == null || ticketType.totalQuantity! <= 0) {
        _debugger.debPrint('Ticket type total quantity is less than or equal to 0', DebugMessageType.error);
        return false;
      }
      if (ticketType.validTimeSlots.isEmpty) {
        _debugger.debPrint('Ticket type valid time slots are empty', DebugMessageType.error);
        return false;
      }
      if (ticketType.description != null && (ticketType.description?.length ?? 0) > 200) {
        _debugger.debPrint('Ticket type description is too long', DebugMessageType.error);
        return false;
      }
      if (ticketType.price.currency == null || ticketType.price.currency!.trim().isEmpty || ticketType.price.currency!.trim().length > 3) {
        _debugger.debPrint('Ticket type price currency is too long or null or empty', DebugMessageType.error);
        return false;
      }
      if (ticketType.price.amount == null || ticketType.price.amount! < 0) {
        _debugger.debPrint('Ticket type price is less than 0', DebugMessageType.error);
        return false;
      }
    }

    return true;
  }

  Widget _buildTicketTypesContainer() {
    return GlassContainer(
      child: Column(
        children: [
          LivitBar(
            shadowType: ShadowType.weak,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [LivitText('Tipos de Tiquetes', textType: LivitTextType.smallTitle)],
            ),
          ),
          _buildTicketsCreation(),
        ],
      ),
    );
  }

  Widget _buildTicketsCreation() {
    _debugger.debPrint('🏗️ [event_creation] _buildTicketsCreation called', DebugMessageType.info);
    return TicketsCreation(
      eventDates: _event.dates,
      initialTickets: _ticketTypes,
      onTicketsChanged: _onTicketsChanged,
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
                EventMediaField(initialMedia: _event.media.media, onMediaChanged: _onMediaChanged),
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
                  child: Button.main(
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

  // Update the method to use the count of dates
  String _getUniqueDateName() {
    int index = _eventDates.length + 1;
    String name = 'Fecha $index';
    while (_eventDates.any((date) => date.name == name)) {
      index++;
      name = 'Fecha $index';
    }

    return name;
  }

  @override
  Widget build(BuildContext context) {
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
                        text: _isSaving ? 'Creando evento...' : 'Crear evento',
                        onTap: _isSaving ? () {} : () => _saveEvent(),
                        isActive: _checkInitialEventValidity() && !_isSaving,
                        isLoading: _isSaving,
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
}
