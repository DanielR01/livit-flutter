import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/services/auth/auth_service.dart';
import 'package:livit/services/crud/livit_db_service.dart';
import 'package:livit/utilities/background/main_background.dart';
import 'package:livit/utilities/bars_containers_fields/navigation_bar.dart';
import 'package:livit/views/main_pages/explore.dart';
import 'package:livit/views/main_pages/home.dart';
import 'package:livit/views/main_pages/profile.dart';
import 'package:livit/views/main_pages/tickets.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  int selectedIndex = 0;
  late final LivitDBService _livitDBService;
  String get userId => AuthService.firebase().currentUser?.id ?? '';

  void onItemPressed(value) {
    setState(
      () {
        selectedIndex = value;
      },
    );
  }

  void _checkIfLoggedIn() {
    if (userId == '') {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(Routes.authRoute, (route) => false);
    }
  }

  @override
  void initState() {
    _livitDBService = LivitDBService();
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _checkIfLoggedIn();
    });
  }

  @override
  void dispose() {
    _livitDBService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: FutureBuilder(
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
                      return Stack(
                        children: [
                          IndexedStack(
                            index: selectedIndex,
                            children: viewsList,
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: CustomNavigationBar(
                              currentIndex: selectedIndex,
                              onItemTapped: onItemPressed,
                            ),
                          ),
                        ],
                      );
                    default:
                      return const LoadingScreen();
                  }
                },
              );
            default:
              return const LoadingScreen();
          }
        },
      ),
    );
  }

  final List<Widget> viewsList = const [
    HomeView(),
    ExploreView(),
    TicketsView(),
    ProfileView(),
  ];
}

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        MainBackground(),
        Center(
          child: CircularProgressIndicator(
            color: LivitColors.whiteInactive,
          ),
        ),
      ],
    );
  }
}
