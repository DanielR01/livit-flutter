import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/utilities/main_background.dart';
import 'package:livit/utilities/navigation_bar.dart';
import 'package:livit/views/explore.dart';
import 'package:livit/views/home.dart';
import 'package:livit/views/profile.dart';
import 'package:livit/views/tickets.dart';

enum MenuAction { logout }

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
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
      // appBar: AppBar(
      //   title: const Text("Main feed"),
      //   actions: [
      //     PopupMenuButton(
      //       onSelected: (value) async {
      //         switch (value) {
      //           case MenuAction.logout:
      //             final shouldLogout = await showLogOutDialog(context);
      //             if (shouldLogout) {
      //               await FirebaseAuth.instance.signOut();
      //               Navigator.of(context).pushNamedAndRemoveUntil(
      //                 loginRoute,
      //                 (route) => false,
      //               );
      //             }
      //         }
      //       },
      //       itemBuilder: (context) {
      //         return const [
      //           PopupMenuItem<MenuAction>(
      //             value: MenuAction.logout,
      //             child: Text('Log out'),
      //           ),
      //         ];
      //       },
      //     ),
      //   ],
      // ),
      body: Stack(
        children: [
          //MainBackground(),
          const Positioned(
            left: 0,
            top: 0,
            child: MainBackground(),
          ),
          // Positioned(
          //   right: 0,
          //   bottom: 70,
          //   child: Container(
          //     color: Colors.white12,
          //     child: const Icon(
          //       color: LivitColors.mainBlueActive,
          //       Icons.circle,
          //       size: 1,
          //     ),
          //   ),
          // ),
          // SafeArea(
          //   child: IndexedStack(
          //     index: selectedIndex,
          //     children: viewsList,
          //   ),
          // ),
          // Align(
          //   alignment: Alignment.bottomCenter,
          //   child: CustomNavigationBar(
          //     currentIndex: selectedIndex,
          //     onItemTapped: onItemPressed,
          //   ),
          // ),
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


