import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/constants/styles/text_style.dart';
import 'package:livit/services/auth/auth_service.dart';
import 'package:livit/utilities/background/main_background.dart';
import 'package:livit/utilities/buttons/action_button.dart';

class ErrorReauthScreen extends StatefulWidget {
  const ErrorReauthScreen({super.key});

  @override
  State<ErrorReauthScreen> createState() => _ErrorReauthScreenState();
}

class _ErrorReauthScreenState extends State<ErrorReauthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const MainBackground(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const LivitText(
                    'Algo salio mal :(',
                    textType: TextType.bigTitle,
                  ),
                  LivitSpaces.small8spacer,
                  const LivitText(
                      'Intenta iniciar sesión de nuevo en unos momentos'),
                  LivitSpaces.mediumPlus24spacer,
                  MainActionButton(
                    text: 'Volver a iniciar sesión',
                    isActive: true,
                    onPressed: () async {
                      await AuthService.firebase().logOut();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          Routes.authRoute, (route) => false);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
