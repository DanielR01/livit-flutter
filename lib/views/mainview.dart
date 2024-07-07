import 'package:flutter/material.dart';
import 'package:livit/utilities/navigation_bar.dart';
import 'package:livit/views/explore.dart';
import 'package:livit/views/home.dart';
import 'package:livit/views/profile.dart';
import 'package:livit/views/tickets.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
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

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
          title: const Text('Log out'),
          content: const Text('Do you want to Log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Log out'),
            ),
          ]);
    },
  ).then((value) => value ?? false);
}
