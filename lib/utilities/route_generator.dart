import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/constants/user_types.dart';
import 'package:livit/views/auth/login/auth_view.dart';
import 'package:livit/views/auth/login/welcome.dart';
import 'package:livit/views/error_route.dart';

class CustomCupertinoPageRoute<T> extends CupertinoPageRoute<T> {
  CustomCupertinoPageRoute({
    required super.builder,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
  });

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return _buildCustomTransition(context, animation, secondaryAnimation, child, super.buildTransitions);
  }
}

Widget _buildCustomTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
  Widget Function(BuildContext, Animation<double>, Animation<double>, Widget) superBuildTransitions,
) {
  const begin = Offset(1.0, 0.0);
  const end = Offset.zero;
  const curve = Curves.easeInOut;
  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

  var offsetAnimation = animation.drive(tween);
  var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ),
  );

  var oldViewTween = Tween(begin: const Offset(0.0, 0.0), end: const Offset(0.0, 1.0)).chain(CurveTween(curve: curve));
  var oldViewAnimation = secondaryAnimation.drive(oldViewTween);

  Widget transitionBuilder(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return Stack(
      children: [
        SlideTransition(
          position: oldViewAnimation,
          child: const SizedBox.expand(),
        ),
        SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        ),
      ],
    );
  }

  return superBuildTransitions(context, animation, secondaryAnimation, transitionBuilder(context, animation, secondaryAnimation, child));
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    Widget page;
    switch (settings.name) {
      case '/':
        page = const AuthWelcomeView();
        break;
      case Routes.authRoute:
        if (args is Map<String, dynamic> && args.containsKey('userType')) {
          final userType = args['userType'] as UserType;
          page = AuthView(userType: userType);
        } else {
          page = AuthView(userType: UserType.customer);
        }
        break;
      default:
        page = ErrorView(
          message: 'Route ${settings.name} not found',
        );
    }

    if (Platform.isIOS) {
      return CustomCupertinoPageRoute(
        builder: (_) => page,
        settings: settings,
      );
    } else {
      return MaterialPageRoute(
        builder: (_) => page,
        settings: settings,
      );
    }
  }
}
