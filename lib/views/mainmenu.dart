import 'package:flutter/material.dart';
import 'package:livit/utilities/bars_containers_fields/navigation_bar.dart';
import 'package:livit/views/explore.dart';
import 'package:livit/views/home.dart';
import 'package:livit/views/profile.dart';
import 'package:livit/views/tickets.dart';

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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
