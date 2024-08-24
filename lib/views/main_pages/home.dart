import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/constants/styles/text_style.dart';
import 'package:livit/services/crud/crud_exceptions.dart';
import 'package:livit/services/crud/livit_db_service.dart';
import 'package:livit/services/crud/tables/events/event.dart';
import 'package:livit/services/crud/tables/users/user.dart';
import 'package:livit/utilities/background/main_background.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/loading_screen.dart';

class HomeView extends StatefulWidget {
  final LivitUser? user;
  const HomeView({
    super.key,
    required this.user,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final LivitDBService _livitDBService;

  @override
  void initState() {
    _livitDBService = LivitDBService();
    _livitDBService.open();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _livitDBService.allEvents,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
              if (snapshot.hasData) {
                List<LivitEvent> events = snapshot.data as List<LivitEvent>;
                return Stack(
                  children: [
                    const MainBackground(),
                    SafeArea(
                      child: Padding(
                        padding: LivitContainerStyle.paddingFromScreen,
                        child: ListView.builder(
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
                        ),
                      ),
                    ),
                  ],
                );
              }
            case ConnectionState.none:
            case ConnectionState.done:
            case ConnectionState.waiting:
              break;
          }
          return const LoadingScreen();
        });
  }
}

class EventPreview extends StatefulWidget {
  final LivitEvent event;
  const EventPreview({
    super.key,
    required this.event,
  });

  @override
  State<EventPreview> createState() => _EventPreviewState();
}

class _EventPreviewState extends State<EventPreview> {
  late final LivitDBService _livitDBService;

  @override
  void initState() {
    _livitDBService = LivitDBService();
    super.initState();
  }

  late String _title;
  late String _location;
  late String _creatorUsername;

  Future<bool> _getEventData() async {
    final LivitEvent event = widget.event;
    try {
      final LivitUser creator =
          await _livitDBService.getUserWithId(id: event.creatorId);
      _title = event.title;
      _location = event.location;
      _creatorUsername = creator.username;

      return true;
    } on UserNotFound {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(LivitContainerStyle.horizontalPadding),
            width: double.infinity,
            child: FutureBuilder(
              future: _getEventData(),
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return Column(
                    children: [
                      LivitText(
                        _title,
                        textType: TextType.smallTitle,
                      ),
                      LivitText(_location),
                      LivitText(_creatorUsername),
                    ],
                  );
                }
                return const Column(
                  children: [
                    LivitText("loading"),
                    LivitText("loading"),
                    LivitText("loading"),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
