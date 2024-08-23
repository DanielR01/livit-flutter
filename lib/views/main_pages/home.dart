import 'package:flutter/cupertino.dart';
import 'package:livit/services/crud/livit_db_service.dart';
import 'package:livit/services/crud/tables/users/user.dart';
import 'package:livit/utilities/background/main_background.dart';
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
    super.initState();
  }

  @override
  void dispose() {
    _livitDBService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _livitDBService.allEvents,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              return const Stack(
                children: [
                  MainBackground(),
                  Center(
                    child: Text('Home'),
                  ),
                ],
              );
            default:
              return const LoadingScreen();
          }
        });
  }
}
