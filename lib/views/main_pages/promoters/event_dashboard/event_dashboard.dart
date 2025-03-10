import 'package:flutter/material.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/utilities/display/livit_display_area.dart';
import 'package:livit/views/main_pages/promoters/event_dashboard/event_location_bar_filter.dart';

class EventDashboard extends StatefulWidget {
  const EventDashboard({super.key});

  @override
  State<EventDashboard> createState() => _EventDashboardState();
}

class _EventDashboardState extends State<EventDashboard> {
  String? _selectedLocationId;

  void _handleLocationSelected(String? locationId) {
    setState(() {
      _selectedLocationId = locationId;
    });
    // Here you would implement filtering logic based on the selected location
  }

  @override
  Widget build(BuildContext context) {
    return LivitDisplayArea(
      child: Column(
        children: [
          EventLocationBarFilter(
            onLocationSelected: _handleLocationSelected,
          ),
          LivitSpaces.m,
          // Rest of your event dashboard content
          // You can use _selectedLocationId to filter events
        ],
      ),
    );
  }
}
