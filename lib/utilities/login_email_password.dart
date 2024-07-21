import 'package:flutter/material.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/enums/credential_types.dart';
import 'package:livit/services/auth/auth_exceptions.dart';
import 'package:livit/services/auth/auth_service.dart';
import 'package:livit/utilities/error_dialogs/show_error_dialog_2t_1b.dart';
import 'package:livit/utilities/error_dialogs/show_error_dialog_2t_2b.dart';

void logInWithEmailAndPassword(
    GlobalKey key, BuildContext context, email, String password) async {
  try {
    await AuthService.firebase().logIn(
      credentialType: CredentialType.emailAndPassword,
      credentials: [email, password],
    );
    final bool emailVerified =
        AuthService.firebase().currentUser?.isEmailVerified ?? false;
    if (!emailVerified) {
      if (context.mounted) {
        await Navigator.of(context).pushNamed(
          Routes.verifyEmailRoute,
        );
      }
    } else {
      if (context.mounted) {
        await Navigator.of(context)
            .pushNamedAndRemoveUntil(Routes.mainviewRoute, (route) => false);
      }
    }
  } on InvalidCredentialsAuthException {
    await showErrorDialog2b(
      [key, null],
      'Invalid email or password',
      'Check if your email and password are correct or try creating an account',
      [
        'Try Again',
        () {
          Navigator.of(context).pop(false);
        },
      ],
      [
        'Create an account',
        () {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(Routes.registerRoute, (route) => false);
        },
      ],
    );
  } on TooManyRequestsAuthException {
    await showErrorDialog(
      key,
      'Too many requests',
      'Try again in a few minutes',
    );
  } on GenericAuthException {
    await showErrorDialog(
      key,
      'Something went wrong',
      'Try again in a few minutes',
    );
  }
}