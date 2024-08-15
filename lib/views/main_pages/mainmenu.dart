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

  void onItemPressed(value) {
    setState(
      () {
        selectedIndex = value;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Stack(
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
