import 'package:flutter/material.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/views/check_initial_auth.dart';
import 'package:livit/views/error_route.dart';
import 'package:livit/views/feed.dart';
import 'package:livit/views/login.dart';
import 'package:livit/views/login_email.dart';
import 'package:livit/views/login_number.dart';
import 'package:livit/views/otp_auth.dart';
import 'package:livit/views/register_email.dart';
import 'package:livit/views/verify_email.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const CheckInitialAuth());
      case loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginView());
      case loginEmailRoute:
        return MaterialPageRoute(builder: (_) => const LoginEmailView());
      case registerEmailRoute:
        return MaterialPageRoute(builder: (_) => const RegisterEmailView());
      case feedRoute:
        return MaterialPageRoute(builder: (_) => const FeedView());
      case verifyEmailRoute:
        return MaterialPageRoute(builder: (_) => const VerifyEmailView());
      case otpAuthRoute:
        if (args is String) {
          return MaterialPageRoute(
              builder: (_) => OtpAuthView(verificationId: args));
        }
        return MaterialPageRoute(builder: (_) => const ErrorView());
      case loginNumberRoute:
        return MaterialPageRoute(builder: (_) => const LoginNumberView());
      default:
        return MaterialPageRoute(builder: (_) => const ErrorView());
    }
  }
}
