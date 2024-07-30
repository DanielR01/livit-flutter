import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/text_style.dart';
import 'package:livit/services/auth/credential_types.dart';
import 'package:livit/services/auth/auth_exceptions.dart';
import 'package:livit/services/auth/auth_service.dart';

class GoogleLoginBar extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final BuildContext parentContext;

  const GoogleLoginBar({
    super.key,
    required this.parentContext,
    required this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          await AuthService.firebase()
              .logIn(credentialType: CredentialType.google, credentials: []);
          if (AuthService.firebase().currentUser != null) {
            if (context.mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.mainviewRoute, (route) => false);
            }
          }
        } on UserNotLoggedInAuthException {
          //Do nothing
        } on GenericAuthException {
          //TODO implement genericAuthException
        }
      },
      child: Container(
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: LivitBarStyle.borderRadius,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 16,
              child: Image.asset(
                'assets/logos/google-logo.png',
                height: 20,
              ),
            ),
            Text(
              'Continuar con Google',
              style: LivitTextStyle(
                //textWeight: FontWeight.bold,
                textColor: LivitColors.mainBlack,
              ).regularTextStyle,
            ),
          ],
        ),
      ),
    );
  }
}
