import 'package:flutter/material.dart';
import 'package:livit/utilities/display/livit_display_area.dart';

class EventDashboard extends StatefulWidget {
  const EventDashboard({super.key});

  @override
  State<EventDashboard> createState() => _EventDashboardState();
}

class _EventDashboardState extends State<EventDashboard> {
  @override
  Widget build(BuildContext context) {
    return const LivitDisplayArea(
      child: Text('Event Dashboard'),
    );
  }
}