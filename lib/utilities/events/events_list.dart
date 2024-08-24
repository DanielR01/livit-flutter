import 'package:flutter/material.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/services/crud/tables/events/event.dart';
import 'package:livit/utilities/events/event_preview.dart';

class EventPreviewList extends StatelessWidget {
  final List<LivitEvent> events;
  const EventPreviewList({
    super.key,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final LivitEvent event = events[index];
        return Column(
          children: [
            EventPreview(event: event),
            LivitSpaces.medium16spacer,
          ],
        );
      },
    );
  }
}