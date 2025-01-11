import 'package:flutter/material.dart';
import 'package:livit/utilities/display/livit_display_area.dart';

class TicketDashboard extends StatefulWidget {
  const TicketDashboard({super.key});

  @override
  State<TicketDashboard> createState() => _TicketDashboardState();
}

class _TicketDashboardState extends State<TicketDashboard> {
  @override
  Widget build(BuildContext context) {
    return const LivitDisplayArea(
      child: Text('Ticket Dashboard'),
    );
  }
}