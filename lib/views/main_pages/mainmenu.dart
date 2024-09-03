import 'package:flutter/material.dart';
import 'package:livit/utilities/bars_containers_fields/navigation_bar.dart';
import 'package:livit/views/main_pages/explore.dart';
import 'package:livit/views/main_pages/home.dart';
import 'package:livit/views/main_pages/profile.dart';
import 'package:livit/views/main_pages/tickets.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({
    super.key,
  });

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  late List<Widget> viewsList;
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
    viewsList = const [
      HomeView(),
      ExploreView(),
      TicketsView(),
      ProfileView(),
    ];
    super.initState();
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
}
