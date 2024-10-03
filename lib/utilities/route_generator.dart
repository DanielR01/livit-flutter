import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/utilities/login/confirm_otp_code.dart';
import 'package:livit/views/auth/initial_router.dart';
import 'package:livit/views/auth/login/auth_view.dart';
import 'package:livit/views/auth/login/email_login.dart';
import 'package:livit/views/auth/login/phone_login.dart';
import 'package:livit/views/error_route.dart';
import 'package:livit/views/main_pages/mainmenu.dart';
import 'package:livit/views/auth/get_or_create_user/get_or_create_user.dart';

class CustomCupertinoPageRoute<T> extends CupertinoPageRoute<T> {
  CustomCupertinoPageRoute({
    required super.builder,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
  });

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final child = super.buildPage(context, animation, secondaryAnimation);
    return _buildCustomTransition(context, animation, secondaryAnimation, child);
  }
}

Widget _buildCustomTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return CupertinoPageTransition(
    primaryRouteAnimation: animation,
    secondaryRouteAnimation: secondaryAnimation,
    linearTransition: false,
    child: child,
  );
}

class CustomMaterialPageRoute<T> extends MaterialPageRoute<T> {
  CustomMaterialPageRoute({
    required super.builder,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
  });

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return _buildCustomMaterialTransition(context, animation, secondaryAnimation, child);
  }
}

Widget _buildCustomMaterialTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  const begin = Offset(1.0, 0.0);
  const end = Offset.zero;
  const curve = Curves.easeInOut;

  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
  var offsetAnimation = animation.drive(tween);

  return SlideTransition(
    position: offsetAnimation,
    child: CupertinoPageTransition(
      primaryRouteAnimation: animation,
      secondaryRouteAnimation: secondaryAnimation,
      linearTransition: false,
      child: child,
    ),
  );
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    Widget page;
    switch (settings.name) {
      case '/':
        page = const InitialRouterView();
        break;
      case Routes.mainViewRoute:
        page = const MainMenu();
        break;
      case Routes.authRoute:
        if (args is Map<String, dynamic> && args.containsKey('userType')) {
          final userType = args['userType'] as UserType;
          page = AuthView(userType: userType);
        } else {
          page = const ErrorView(message: 'No se proporcionó el tipo de usuario.');
        }
        break;
      case Routes.loginPhoneNumberRoute:
        if (args is Map<String, dynamic> && args.containsKey('userType')) {
          final userType = args['userType'] as UserType;
          page = PhoneLoginView(userType: userType);
        } else {
          page = const ErrorView(message: 'No se proporcionó el tipo de usuario.');
        }
        break;
      case Routes.confirmOTPCodeRoute:
        if (args is Map<String, dynamic> &&
            args.containsKey('userType') &&
            args.containsKey('phoneCode') &&
            args.containsKey('initialVerificationId') &&
            args.containsKey('phoneNumber')) {
          final userType = args['userType'] as UserType;
          final phoneCode = args['phoneCode'] as String;
          final initialVerificationId = args['initialVerificationId'] as String;
          final phoneNumber = args['phoneNumber'] as String;
          page = ConfirmOTPCodeView(
            userType: userType,
            phoneCode: phoneCode,
            initialVerificationId: initialVerificationId,
            phoneNumber: phoneNumber,
          );
        } else {
          page = const ErrorView(message: 'No se proporcionó toda la información necesaria.');
        }
        break;
      case Routes.loginEmailRoute:
        if (args is Map<String, dynamic> && args.containsKey('userType')) {
          final userType = args['userType'] as UserType;
          page = EmailLoginView(userType: userType);
        } else {
          page = const ErrorView(message: 'No se proporcionó el tipo de usuario.');
        }
        break;
      case Routes.getOrCreateUserRoute:
        if (args is Map<String, dynamic> && args.containsKey('userType')) {
          final userType = args['userType'] as UserType;
          page = GetOrCreateUserView(userType: userType);
        } else {
          page = const ErrorView(message: 'No se proporcionó el tipo de usuario.');
        }
        break;
      default:
        page = ErrorView(
          message: 'Ruta ${settings.name} no encontrada',
        );
    }

    if (Platform.isIOS) {
      return CustomCupertinoPageRoute(
        builder: (_) => page,
        settings: settings,
      );
    } else {
      return CustomMaterialPageRoute(
        builder: (_) => page,
        settings: settings,
      );
    }
  }
}
