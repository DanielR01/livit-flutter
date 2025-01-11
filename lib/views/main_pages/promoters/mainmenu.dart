// import 'package:flutter/material.dart';
// import 'package:livit/utilities/bars_containers_fields/navigation_bar.dart';

// class MainMenuPromoter extends StatefulWidget {
//   const MainMenuPromoter({
//     super.key,
//   });

//   @override
//   State<MainMenuPromoter> createState() => _MainMenuPromoterState();
// }

// class _MainMenuPromoterState extends State<MainMenuPromoter> {
//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
//   late List<Widget> viewsList;
//   int selectedIndex = 0;

//   void onItemPressed(value) {
//     setState(
//       () {
//         selectedIndex = value;
//       },
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: scaffoldKey,
//       body: Stack(
//         children: [
//           IndexedStack(
//             index: selectedIndex,
//             children: viewsList,
//           ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: CustomNavigationBar(
//               currentIndex: selectedIndex,
//               onItemTapped: onItemPressed,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
