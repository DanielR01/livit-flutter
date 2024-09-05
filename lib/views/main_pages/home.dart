import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/services/auth/auth_service.dart';
import 'package:livit/services/cloud/cloud_event.dart';
import 'package:livit/services/cloud/firebase_cloud_storage.dart';
import 'package:livit/utilities/background/main_background.dart';
import 'package:livit/utilities/events/events_list.dart';
import 'package:livit/utilities/loading_screen.dart';

class HomeView extends StatefulWidget {
  const HomeView({
    super.key,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final FirebaseCloudStorage _livitDBService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _livitDBService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const MainBackground(),
        StreamBuilder(
          stream: _livitDBService.allEvents(creatorId: userId),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.active:
                if (snapshot.hasData) {
                  final Iterable<CloudEvent> events = snapshot.data as Iterable<CloudEvent>;
                  return SafeArea(
                    child: Padding(
                      padding: LivitContainerStyle.paddingFromScreen,
                      child: EventPreviewList(
                        events: events,
                        onDeleteEvent: (event) {
                          _livitDBService.deleteEvent(documentId: event.documentId);
                        },
                        onEditEvent: (event) {
                          Navigator.of(context).pushNamed(
                            Routes.createUpdateEventRoute,
                            arguments: event,
                          );
                        },
                      ),
                    ),
                  );
                }
                return const LoadingScreen();
              case ConnectionState.none:
              case ConnectionState.done:
              case ConnectionState.waiting:
                return const LoadingScreen();
            }
          },
        ),
      ],
    );
  }
}
