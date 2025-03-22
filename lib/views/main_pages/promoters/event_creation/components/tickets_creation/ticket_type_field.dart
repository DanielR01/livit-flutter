import 'package:flutter/material.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/models/event/event.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';

class TicketTypeField extends StatefulWidget {
  final EventTicketType ticketType;
  const TicketTypeField({super.key, required this.ticketType});

  @override
  State<TicketTypeField> createState() => _TicketTypeFieldState();
}

class _TicketTypeFieldState extends State<TicketTypeField> {
  @override
  Widget build(BuildContext context) {
    return LivitBar(
      child: Center(
        child: LivitText('Tiquete'),
      ),
    );
  }
}