import 'package:flutter/material.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/views/auth.dart';
import 'package:livit/views/check_initial_auth.dart';
import 'package:livit/views/error_route.dart';
import 'package:livit/views/mainmenu.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const CheckInitialAuth());
      case Routes.authRoute:
        return MaterialPageRoute(builder: (_) => const AuthView());
      case Routes.mainviewRoute:
        return MaterialPageRoute(builder: (_) => const MainMenu());
      default:
        return MaterialPageRoute(builder: (_) => const ErrorView());
    }
  }
}
