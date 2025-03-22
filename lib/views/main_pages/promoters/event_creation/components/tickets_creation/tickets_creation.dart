import 'package:flutter/material.dart';
import 'package:livit/models/event/event.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/views/main_pages/promoters/event_creation/components/tickets_creation/ticket_type_field.dart';

class TicketsCreation extends StatefulWidget {
  final List<EventDate> eventDates;
  const TicketsCreation({super.key, required this.eventDates});

  @override
  State<TicketsCreation> createState() => _TicketsCreationState();
}

class _TicketsCreationState extends State<TicketsCreation> {
  List<EventTicketType> _ticketTypes = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var ticketType in _ticketTypes)
          TicketTypeField(
            ticketType: ticketType,
          ),
        Button.main(
            text: 'Agregar tiquete',
            isActive: true,
            onTap: () {
              setState(() {
                _ticketTypes.add(EventTicketType.empty());
              });
            }),
      ],
    );
  }
}
