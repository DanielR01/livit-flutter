import 'package:flutter/material.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/views/check_initial_auth.dart';
import 'package:livit/views/error_route.dart';
import 'package:livit/views/mainmenu.dart';
import 'package:livit/views/login.dart';
import 'package:livit/views/login_email.dart';
import 'package:livit/views/phone_number_auth.dart';
import 'package:livit/views/otp_auth.dart';
import 'package:livit/views/register.dart';
import 'package:livit/views/register_email.dart';
import 'package:livit/views/verify_email.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const CheckInitialAuth());
      case Routes.loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginView());
      case Routes.loginEmailRoute:
        return MaterialPageRoute(builder: (_) => const LoginEmailView());
      case Routes.registerEmailRoute:
        return MaterialPageRoute(builder: (_) => const RegisterEmailView());
      case Routes.mainviewRoute:
        return MaterialPageRoute(builder: (_) => const MainMenu());
      case Routes.verifyEmailRoute:
        return MaterialPageRoute(builder: (_) => const VerifyEmailView());
      case Routes.otpAuthRoute:
        if (args is String) {
          return MaterialPageRoute(
              builder: (_) => OtpAuthView(verificationId: args));
        }
        return MaterialPageRoute(builder: (_) => const ErrorView());
      case Routes.authNumberRoute:
        if (args is bool) {
          return MaterialPageRoute(
              builder: (_) => AuthNumberView(isLogin: args));
        }
        return MaterialPageRoute(builder: (_) => const ErrorView());
      case Routes.registerRoute:
        return MaterialPageRoute(builder: (_) => const RegisterView());
      default:
        return MaterialPageRoute(builder: (_) => const ErrorView());
    }
  }
}
