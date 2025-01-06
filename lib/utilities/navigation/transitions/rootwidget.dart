import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/services/auth/bloc/auth_bloc.dart';
import 'package:livit/services/auth/bloc/auth_state.dart';
import 'package:livit/services/background/background_bloc.dart';
import 'package:livit/services/background/background_states.dart';
import 'dart:io';
import 'package:livit/utilities/background/main_background.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/dialogs/generic_dialog.dart';
import 'package:livit/utilities/navigation/route_generator.dart';

class RootWidgetBackground extends StatefulWidget {
  const RootWidgetBackground({super.key});

  @override
  State<RootWidgetBackground> createState() => _RootWidgetBackgroundState();
}

class _RootWidgetBackgroundState extends State<RootWidgetBackground> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  bool _isLoggedOut = true;

  @override
  Widget build(BuildContext context) {
    Widget content = BlocBuilder<BackgroundBloc, BackgroundState>(
      buildWhen: (previous, current) => previous.isBackgroundGenerated != current.isBackgroundGenerated,
      builder: (context, state) {
        return Stack(
          children: [
            MainBackground(),
            if (state.isBackgroundGenerated)
              BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthStateLoggedOut && !_isLoggedOut) {
                    _isLoggedOut = true;
                    debugPrint('🚪 [RootWidgetBackground] Routing to welcome');
                    navigatorKey.currentState?.pushNamedAndRemoveUntil(Routes.welcomeRoute, (route) => false);
                  } else if (state is AuthStateLoggedIn) {
                    _isLoggedOut = false;
                  }
                },
                child: Navigator(
                  key: navigatorKey,
                  initialRoute: '/',
                  onGenerateRoute: RouteGenerator.generateRoute,
                ),
              ),
          ],
        );
      },
    );
    if (Platform.isAndroid) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) async {
          if (didPop) return;

          final NavigatorState? navigator = navigatorKey.currentState;
          if (navigator == null) return;

          if (navigator.canPop()) {
            navigator.pop();
          } else {
            // We're at the root route, show a dialog to confirm exit
            final shouldPop = await showGenericDialog<bool>(
              context: navigator.context,
              title: 'Exit App',
              content: 'Do you want to exit the app?',
              optionBuilder: () => {
                'No': {'return': false, 'buttonType': ButtonType.main},
                'Yes': {'return': true, 'buttonType': ButtonType.redText},
              },
            );
            if (shouldPop ?? false) {
              // Here you would typically call a method to exit the app
              // For example: SystemNavigator.pop();
              debugPrint('Exiting app');
            }
          }
        },
        child: content,
      );
    } else {
      return content;
    }
  }
}
