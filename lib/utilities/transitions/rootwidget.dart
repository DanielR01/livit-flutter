import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:livit/utilities/background/main_background.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/route_generator.dart';
import 'package:livit/utilities/dialogs/generic_dialog.dart';

class RootWidgetBackground extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  RootWidgetBackground({super.key});

  @override
  Widget build(BuildContext context) {
    Widget content = Stack(
      children: [
        MainBackground.colorful(),
        Navigator(
          key: navigatorKey,
          initialRoute: '/',
          onGenerateRoute: RouteGenerator.generateRoute,
        ),
      ],
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
              print('Exiting app');
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
