import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/models/event/event.dart';
import 'package:livit/models/price/price.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/debug/livit_debugger.dart';
import 'package:livit/views/main_pages/promoters/event_creation/components/tickets_creation/ticket_type_field.dart';

class TicketsCreation extends StatefulWidget {
  final List<EventDate> eventDates;
  final List<EventTicketType> initialTickets;
  final Function(List<EventTicketType>) onTicketsChanged;

  const TicketsCreation({
    super.key,
    required this.eventDates,
    required this.initialTickets,
    required this.onTicketsChanged,
  });

  @override
  State<TicketsCreation> createState() => _TicketsCreationState();
}

class _TicketsCreationState extends State<TicketsCreation> {
  late List<EventTicketType> _ticketTypes;
  final LivitDebugger _debugger = const LivitDebugger('tickets_creation', isDebugEnabled: true);

  @override
  void initState() {
    super.initState();
    _ticketTypes = List.from(widget.initialTickets);
    _debugger.debPrint('Initialized with ${_ticketTypes.length} tickets', DebugMessageType.info);
  }

  @override
  void didUpdateWidget(TicketsCreation oldWidget) {
    super.didUpdateWidget(oldWidget);

    _debugger.debPrint(
        'Widget updated - dates: ${widget.eventDates.length}, tickets: ${widget.initialTickets.length}', DebugMessageType.updating);

    // Keep existing tickets when dates change, but update date references if needed
    if (!listEquals(widget.eventDates, oldWidget.eventDates)) {
      _debugger.debPrint('Event dates changed', DebugMessageType.info);
      _debugger.debPrint('Event dates: ${widget.eventDates}', DebugMessageType.info);
      _debugger.debPrint('Old event dates: ${oldWidget.eventDates}', DebugMessageType.info);
      _debugger.debPrint('Validating ticket dates', DebugMessageType.verifying);
      _validateTicketDates(widget.eventDates);
    }

    // Only update the tickets list if the initialTickets changed and it's not just
    // due to date references being updated
    if (!_areTicketListsEqual(widget.initialTickets, _ticketTypes)) {
      _debugger.debPrint('Initial tickets changed significantly, updating local state', DebugMessageType.updating);
      _safeSetState(() {
        _ticketTypes = List.from(widget.initialTickets);
      });
    }
  }

  void _validateTicketDates(List<EventDate> newEventDates) {
    final List<EventDateTimeSlot> newAvailableTimeSlots =
        newEventDates.map((d) => EventDateTimeSlot(dateName: d.name, startTime: d.startTime, endTime: d.endTime)).toList();
    bool hasChanges = false;
    _debugger.debPrint('Valid date time slots: $newAvailableTimeSlots', DebugMessageType.info);

    for (int i = 0; i < _ticketTypes.length; i++) {
      final List<EventDateTimeSlot> timeSlotsToRemove = [];
      for (final timeSlot in _ticketTypes[i].validTimeSlots) {
        bool timeSlotIsValid = newAvailableTimeSlots.any((availableSlot) =>
            availableSlot.dateName == timeSlot.dateName &&
            availableSlot.startTime.seconds == timeSlot.startTime.seconds &&
            availableSlot.endTime.seconds == timeSlot.endTime.seconds);

        if (!timeSlotIsValid) {
          _debugger.debPrint('Time slot is not valid', DebugMessageType.warning);
          timeSlotsToRemove.add(timeSlot);
          hasChanges = true;
        }
      }
      _ticketTypes[i].validTimeSlots.removeWhere((timeSlot) => timeSlotsToRemove.contains(timeSlot));
    }

    if (hasChanges) {
      _debugger.debPrint('Ticket dates were updated', DebugMessageType.done);
      _debugger.debPrint('New ticket types: $_ticketTypes', DebugMessageType.info);
      _debugger.debPrint('Notifying parent', DebugMessageType.methodCalling);
      _safeSetState(() {});
      _notifyTicketsChanged();
    } else {
      _debugger.debPrint('No ticket date changes needed', DebugMessageType.info);
    }
  }

  void _onDeleteTicketType(EventTicketType ticketType) {
    _debugger.debPrint('Deleting ticket type: ${ticketType.name}', DebugMessageType.deleting);
    _safeSetState(() {
      _ticketTypes.remove(ticketType);
      _notifyTicketsChanged();
    });
  }

  void _onUpdateTicketType(EventTicketType oldTicket, EventTicketType updatedTicket) {
    _debugger.debPrint('Updating ticket type', DebugMessageType.updating);

    _safeSetState(() {
      final index = _ticketTypes.indexOf(oldTicket);
      if (index != -1) {
        _ticketTypes[index] = updatedTicket;
        _notifyTicketsChanged();
      }
    });
  }

  void _notifyTicketsChanged() {
    _debugger.debPrint('Notifying parent of ticket changes', DebugMessageType.methodCalling);
    widget.onTicketsChanged(_ticketTypes);
  }

  // Helper method to compare ticket lists ignoring just date reference changes
  bool _areTicketListsEqual(List<EventTicketType> list1, List<EventTicketType> list2) {
    if (list1.length != list2.length) return false;

    for (int i = 0; i < list1.length; i++) {
      // Check all fields except dateName which might have been auto-updated
      if (list1[i].name != list2[i].name ||
          list1[i].totalQuantity != list2[i].totalQuantity ||
          list1[i].description != list2[i].description ||
          list1[i].price.amount != list2[i].price.amount ||
          list1[i].validTimeSlots != list2[i].validTimeSlots) {
        return false;
      }
    }

    return true;
  }

  // Add this helper method to safely call setState
  void _safeSetState(VoidCallback fn) {
    _debugger.debPrint(
        'Safe setState called - build phase: ${WidgetsBinding.instance.buildOwner?.debugBuilding ?? false}', DebugMessageType.building);

    if (WidgetsBinding.instance.buildOwner?.debugBuilding ?? false) {
      _debugger.debPrint('Deferring setState to post-frame callback', DebugMessageType.warning);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(fn);
        }
      });
    } else {
      if (mounted) {
        setState(fn);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: LivitContainerStyle.padding(),
      child: Column(
        children: [
          LivitText(
            'Agrega los tiquetes que quieres ofrecer para este evento.',
            color: LivitColors.whiteInactive,
          ),
          LivitSpaces.m,
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => TicketTypeField(
              ticketType: _ticketTypes[index],
              onDelete: _onDeleteTicketType,
              onUpdate: _onUpdateTicketType,
              availableDates: widget.eventDates,
            ),
            separatorBuilder: (context, index) => LivitSpaces.m,
            itemCount: _ticketTypes.length,
          ),
          if (_ticketTypes.isEmpty)
            LivitBar(
              shadowType: ShadowType.weak,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.exclamationmark_circle,
                      color: LivitColors.whiteActive,
                      size: LivitButtonStyle.iconSize,
                    ),
                    LivitSpaces.xs,
                    LivitText('No has creado ningún tiquete'),
                  ],
                ),
              ),
            ),
          LivitSpaces.m,
          Row(
            children: [
              Expanded(
                child: Button.main(
                    text: 'Agregar tiquete',
                    rightIcon: CupertinoIcons.ticket,
                    isActive: true,
                    onTap: () {
                      final newTicket = EventTicketType.empty(price: LivitPrice.empty(currency: 'COP'));

                      _debugger.debPrint('Adding new empty ticket', DebugMessageType.creating);
                      setState(() {
                        _ticketTypes.add(newTicket);
                        _notifyTicketsChanged();
                      });
                    }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
