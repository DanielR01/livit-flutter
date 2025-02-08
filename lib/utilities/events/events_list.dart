import 'package:flutter/material.dart';
import 'package:livit/models/event/event.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/utilities/dialogs/delete_event_dialog.dart';
import 'package:livit/utilities/events/event_preview.dart';

typedef EventCallback = void Function(LivitEvent event);

class EventPreviewList extends StatefulWidget {
  final Iterable<LivitEvent> events;
  final EventCallback onDeleteEvent;
  final EventCallback onEditEvent;
  const EventPreviewList({
    super.key,
    required this.events,
    required this.onDeleteEvent,
    required this.onEditEvent,
  });

  @override
  State<EventPreviewList> createState() => _EventPreviewListState();
}

class _EventPreviewListState extends State<EventPreviewList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: widget.events.length,
      separatorBuilder: (context, index) => LivitSpaces.m,
      itemBuilder: (context, index) {
        final LivitEvent event = widget.events.elementAt(index);
        return EventPreview(
          event: event,
        );
      },
    );
  }
}
