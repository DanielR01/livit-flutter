import 'package:flutter/material.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/display/livit_display_area.dart';
import 'package:livit/views/main_pages/promoters/location_detail/location_detail.dart';

class EventDashboard extends StatefulWidget {
  const EventDashboard({super.key});

  @override
  State<EventDashboard> createState() => _EventDashboardState();
}

class _EventDashboardState extends State<EventDashboard> {
  @override
  Widget build(BuildContext context) {
    return const LivitDisplayArea(
      child: LocationDescription(description: ''),
    );
  }
}
