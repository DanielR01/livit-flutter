import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livit/services/cloud/firebase_cloud_storage.dart';

class HomeView extends StatefulWidget {
  const HomeView({
    super.key,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final FirebaseCloudStorage _livitDBService;
  //String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _livitDBService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // StreamBuilder(
        //   stream: _livitDBService.allEvents(creatorId: userId),
        //   builder: (context, snapshot) {
        //     switch (snapshot.connectionState) {
        //       case ConnectionState.active:
        //         if (snapshot.hasData) {
        //           final Iterable<CloudEvent> events = snapshot.data as Iterable<CloudEvent>;
        //           return SafeArea(
        //             child: Padding(
        //               padding: LivitContainerStyle.paddingFromScreen,
        //               child: EventPreviewList(
        //                 events: events,
        //                 onDeleteEvent: (event) {
        //                   _livitDBService.deleteEvent(documentId: event.documentId);
        //                 },
        //                 onEditEvent: (event) {
        //                   Navigator.of(context).pushNamed(
        //                     Routes.createUpdateEventRoute,
        //                     arguments: event,
        //                   );
        //                 },
        //               ),
        //             ),
        //           );
        //         }
        //         return const LoadingScreen();
        //       case ConnectionState.none:
        //       case ConnectionState.done:
        //       case ConnectionState.waiting:
        //         return const LoadingScreen();
        //     }
        //   },
        // ),
      ],
    );
  }
}
