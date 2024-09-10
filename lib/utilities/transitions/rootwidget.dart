import 'package:flutter/material.dart';
import 'package:livit/utilities/background/main_background.dart';
import 'package:livit/utilities/route_generator.dart';

class RootWidgetBackground extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  RootWidgetBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const MainBackground(),
        Navigator(
          key: navigatorKey,
          initialRoute: '/',
          onGenerateRoute: RouteGenerator.generateRoute,
        ),
      ],
    );
  }
}