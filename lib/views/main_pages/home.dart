import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/services/crud/livit_db_service.dart';
import 'package:livit/services/crud/tables/events/event.dart';
import 'package:livit/services/crud/tables/users/user.dart';
import 'package:livit/utilities/background/main_background.dart';
import 'package:livit/utilities/events/events_list.dart';
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
                        child: EventPreviewList(
                          events: events,
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
