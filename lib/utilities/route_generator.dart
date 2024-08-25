import 'package:flutter/material.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/services/crud/livit_db_service.dart';
import 'package:livit/services/crud/tables/events/event.dart';
import 'package:livit/services/crud/tables/users/user.dart';
import 'package:livit/views/auth/get_or_create_user.dart';
import 'package:livit/views/auth/sign_in/auth.dart';
import 'package:livit/views/auth/check_initial_auth.dart';
import 'package:livit/views/error_route.dart';
import 'package:livit/views/main_pages/mainmenu.dart';
import 'package:livit/views/promoters/create_update_event.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const CheckInitialAuth());
      case Routes.authRoute:
        return MaterialPageRoute(builder: (_) => const AuthView());
      case Routes.mainviewRoute:
        if (args is LivitUser?) {
          return MaterialPageRoute(
            builder: (_) => MainMenu(
              user: args,
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => const ErrorView());
      case Routes.createUpdateEventRoute:
        if (args is LivitEvent?) {
          return MaterialPageRoute(
            builder: (_) => CreateUpdateEventView(
              event: args,
            ),
          );
        }

      case Routes.getOrCreateUserRoute:
        if (args is UserType?) {
          return MaterialPageRoute(
            builder: (_) => GetOrCreateUserView(
              userType: args,
            ),
          );
        }

      default:
        break;
    }
    return MaterialPageRoute(builder: (_) => const ErrorView());
  }
}
