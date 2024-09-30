import 'package:flutter/material.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/utilities/buttons/button.dart';

class ErrorView extends StatelessWidget {
  final String message;
  const ErrorView({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: LivitContainerStyle.paddingFromScreen,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const LivitText(
                  '¡Ups!',
                  textStyle: TextType.bigTitle,
                ),
                //LivitSpaces.s,
                const LivitText(
                  'Algo salió mal, intenta de nuevo en unos minutos.',
                  textAlign: TextAlign.center,
                ),
                LivitSpaces.s,
                const LivitText(
                  'Parece que el problema es:',
                ),
                LivitText(
                  message,
                ),
                LivitSpaces.m,
                Button.main(
                  isActive: true,
                  text: 'Volver',
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        Routes.authRoute,
                        arguments: {
                          'userType': UserType.customer,
                        },
                        (route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
