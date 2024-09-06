import 'package:flutter/material.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/services/cloud/cloud_event.dart';
import 'package:livit/services/cloud/firebase_cloud_storage.dart';
import 'package:livit/utilities/login/confirm_otp_code.dart';
import 'package:livit/utilities/login/email_login.dart';
import 'package:livit/views/auth/initial_router.dart';
import 'package:livit/views/auth/login/login.dart';
import 'package:livit/views/auth/login/welcome.dart';
import 'package:livit/views/error_route.dart';
import 'package:livit/views/main_pages/mainmenu.dart';
import 'package:livit/views/promoters/create_update_event.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const InitialRouterView());
      case Routes.welcomeRoute:
        return MaterialPageRoute(builder: (_) => const AuthWelcomeView());
      case Routes.signInRoute:
        if (args is UserType) {
          return MaterialPageRoute(
            builder: (_) => LoginView(userType: args),
          );
        }
      case Routes.emailAndPasswordRoute:
        if (args is UserType) {
          return MaterialPageRoute(
            builder: (_) => EmailLogin(
              userType: args,
            ),
          );
        }
      case Routes.confirmOTPCodeRoute:
        if (args is Map<String, dynamic>) {
          try {
            final UserType userType = args['userType'];
            final String phoneCode = args['phoneCode'];
            final String initialVerificationId = args['verificationId'];
            final String phoneNumber = args['phoneNumber'];
            return MaterialPageRoute(
              builder: (_) => ConfirmOTPCodeView(
                userType: userType,
                phoneCode: phoneCode,
                initialVerificationId: initialVerificationId,
                phoneNumber: phoneNumber,
              ),
            );
          } finally {}
        }
      case Routes.mainviewRoute:
        return MaterialPageRoute(
          builder: (_) => const MainMenu(),
        );

      case Routes.createUpdateEventRoute:
        if (args is CloudEvent?) {
          return MaterialPageRoute(
            builder: (_) => CreateUpdateEventView(
              event: args,
            ),
          );
        }

      // case Routes.getOrCreateUserRoute:
      //   if (args is UserType?) {
      //     return MaterialPageRoute(
      //       builder: (_) => GetOrCreateUserView(
      //         userType: args,
      //       ),
      //     );
      //   }
    }
    return MaterialPageRoute(builder: (_) => const ErrorView());
  }
}
