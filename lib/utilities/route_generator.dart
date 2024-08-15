import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/services/crud/livit_db_service.dart';
import 'package:livit/views/auth/get_or_create_user.dart';
import 'package:livit/views/auth/sign_in/auth.dart';
import 'package:livit/views/auth/check_initial_auth.dart';
import 'package:livit/views/error_route.dart';
import 'package:livit/views/main_pages/mainmenu.dart';
import 'package:livit/views/promoters/new_event.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const CheckInitialAuth());
      case Routes.authRoute:
        return MaterialPageRoute(builder: (_) => const AuthView());
      case Routes.mainviewRoute:
        return MaterialPageRoute(builder: (_) => const MainMenu());
      case Routes.newEventRoute:
        return MaterialPageRoute(builder: (_) => const NewEventView());
      case Routes.getOrCreateUserRoute:
        if (args is UserType) {
          return MaterialPageRoute(
            builder: (_) => GetOrCreateUserView(
              userType: args,
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => const ErrorView());

      default:
        return MaterialPageRoute(builder: (_) => const ErrorView());
    }
  }
}
