import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/models/location/location.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/services/background/background_bloc.dart';
import 'package:livit/services/background/background_events.dart';
import 'package:livit/services/navigation/navigation_service.dart';
import 'package:livit/utilities/loading_screen.dart';
import 'package:livit/utilities/login/confirm_otp_code.dart';
import 'package:livit/utilities/media/media_preview_player/location_media_preview_player.dart';
import 'package:livit/views/auth/initial_router.dart';
import 'package:livit/views/auth/login/auth_view.dart';
import 'package:livit/views/auth/login/email_login.dart';
import 'package:livit/views/auth/login/phone_login.dart';
import 'package:livit/views/auth/login/welcome.dart';
import 'package:livit/views/errors/error_route.dart';
import 'package:livit/views/errors/splash.dart';
import 'package:livit/views/main_pages/promoters/main_menu_promoter.dart';
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
    debugPrint('RouteGenerator: ${settings.name}');
    Widget page;
    switch (settings.name) {
      case '/':
        page = const InitialRouterView();
        break;
      case Routes.welcomeRoute:
        final context = navigatorKey.currentContext;
        if (context != null) {
          BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundSpeedNormal());
        }
        page = const WelcomeView();
        break;
      case Routes.mainViewRoute:
        if (args is Map<String, dynamic> && args.containsKey('userType')) {
          final userType = args['userType'] as UserType;
          switch (userType) {
            // TODO: Add remaining views
            case UserType.scanner:
              page = const LoadingScreen();
              break;
            case UserType.promoter:
              page = const MainMenuPromoter();
              break;
            case UserType.customer:
              page = const LoadingScreen();
              break;
          }
        } else {
          page = const ErrorView(message: 'No se proporcionó el tipo de usuario.');
        }
        break;
      case Routes.authRoute:
        _animateBackgroundSpeed();
        if (args is Map<String, dynamic> && args.containsKey('userType')) {
          final userType = args['userType'] as UserType;
          page = AuthView(userType: userType);
        } else {
          page = const ErrorView(message: 'No se proporcionó el tipo de usuario.');
        }
        break;
      case Routes.loginPhoneNumberRoute:
        _animateBackgroundSpeed();
        if (args is Map<String, dynamic> && args.containsKey('userType')) {
          final userType = args['userType'] as UserType;
          page = PhoneLoginView(userType: userType);
        } else {
          page = const ErrorView(message: 'No se proporcionó el tipo de usuario.');
        }
        break;
      case Routes.confirmOTPCodeRoute:
        _animateBackgroundSpeed();
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
        _animateBackgroundSpeed();
        if (args is Map<String, dynamic> && args.containsKey('userType')) {
          final userType = args['userType'] as UserType;
          page = EmailLoginView(userType: userType);
        } else {
          page = const ErrorView(message: 'No se proporcionó el tipo de usuario.');
        }
        break;
      case Routes.getOrCreateUserRoute:
        _animateBackgroundSpeed();
        if (args is Map<String, dynamic> && args.containsKey('userType')) {
          final userType = args['userType'] as UserType;
          page = GetOrCreateUserView(userType: userType);
        } else {
          page = GetOrCreateUserView(userType: null);
        }
        break;
      case Routes.locationMediaPreviewPlayerRoute:
        if (args is Map<String, dynamic> && args.containsKey('location')) {
          final location = args['location'] as LivitLocation;
          final index = args['index'] as int?;
          final addMedia = args['addMedia'] as bool?;
          page = LocationMediaPreviewPlayer(location: location, index: index ?? 0, addMedia: addMedia ?? false);
        } else {
          page = const ErrorView(message: 'No se proporcionó la ubicación.');
        }
        break;
      case Routes.splashRoute:
        page = const SplashView();
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

void _animateBackgroundSpeed() {
  final context = navigatorKey.currentContext;
  if (context == null) return;
  BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundStartTransitionAnimation());
  Future.delayed(const Duration(milliseconds: 800), () {
    if (context.mounted) {
      BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundStopTransitionAnimation());
    }
  });
}
