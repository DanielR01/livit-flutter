import 'package:flutter/cupertino.dart';
import 'package:livit/services/auth/auth_service.dart';
import 'package:livit/services/crud/livit_db_service.dart';
import 'package:livit/utilities/loading_screen.dart';
import 'package:livit/views/main_pages/mainmenu.dart';

class GetOrCreateUserView extends StatefulWidget {
  final UserType userType;
  const GetOrCreateUserView({
    super.key,
    required this.userType,
  });

  @override
  State<GetOrCreateUserView> createState() => _GetOrCreateUserViewState();
}

class _GetOrCreateUserViewState extends State<GetOrCreateUserView> {
  late final LivitDBService _livitDBService;
  String get userId => AuthService.firebase().currentUser!.id!;

  @override
  void initState() {
    _livitDBService = LivitDBService();
    _livitDBService.open();
    super.initState();
  }

  @override
  void dispose() {
    _livitDBService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _livitDBService.getOrCreateUser(userId: userId),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return StreamBuilder(
              stream: _livitDBService.allEvents,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.active:
                    return const Text('hello');
                  default:
                    return const LoadingScreen();
                }
              },
            );
          default:
            return const LoadingScreen();
        }
      },
    );
  }
}
