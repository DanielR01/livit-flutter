import 'package:flutter/material.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/services/crud/livit_db_service.dart';
import 'package:livit/services/crud/tables/events/event.dart';
import 'package:livit/services/crud/tables/users/user.dart';
import 'package:livit/utilities/dialogs/delete_event_dialog.dart';
import 'package:livit/utilities/events/event_preview.dart';

typedef DeleteEventCallback = void Function(LivitEvent event);

class EventPreviewList extends StatefulWidget {
  final List<LivitEvent> events;
  final DeleteEventCallback onDeleteEvent;
  const EventPreviewList({
    super.key,
    required this.events,
    required this.onDeleteEvent,
  });

  @override
  State<EventPreviewList> createState() => _EventPreviewListState();
}

class _EventPreviewListState extends State<EventPreviewList> {
  late final LivitDBService _livitDBService;

  @override
  void initState() {
    _livitDBService = LivitDBService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: widget.events.length,
      separatorBuilder: (context, index) => LivitSpaces.medium16spacer,
      itemBuilder: (context, index) {
        final LivitEvent event = widget.events[index];
        return FutureBuilder<LivitUser?>(
          future: _livitDBService.getUserWithId(id: event.creatorId),
          builder: (context, AsyncSnapshot<LivitUser?> snapshot) {
            EventPreview eventPreview = EventPreview.loading();
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                final LivitUser? user = snapshot.data;
                if (user != null) {
                  eventPreview = EventPreview(
                    event: event,
                    user: user,
                    onDeletePressed: () async {
                      final bool shouldDelete =
                          await showDeleteEventDialog(context: context);
                      if (shouldDelete) {
                        widget.onDeleteEvent(event);
                      }
                    },
                  );
                } else {
                  eventPreview = EventPreview.error();
                }
              } else if (snapshot.hasError) {
                eventPreview = EventPreview.error();
              }
            }
            return eventPreview;
          },
        );
      },
    );
  }
}
