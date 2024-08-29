import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/text_style.dart';
import 'package:livit/services/auth/credential_types.dart';
import 'package:livit/services/auth/auth_exceptions.dart';
import 'package:livit/services/auth/auth_service.dart';
import 'package:livit/services/crud/livit_db_service.dart';

class GoogleLoginBar extends StatefulWidget {
  final UserType userType;
  const GoogleLoginBar({
    super.key,
    required this.userType,
  });

  @override
  State<GoogleLoginBar> createState() => _GoogleLoginBarState();
}

class _GoogleLoginBarState extends State<GoogleLoginBar> {
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        setState(
          () {
            _isSigningIn = true;
          },
        );
        try {
          await AuthService.firebase()
              .logIn(credentialType: CredentialType.google, credentials: []);
          if (AuthService.firebase().currentUser != null) {
            if (context.mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.getOrCreateUserRoute,
                  arguments: widget.userType,
                  (route) => false);
            }
          }
        } on UserNotLoggedInAuthException {
          //Do nothing
        } on GenericAuthException {
          //TODO implement genericAuthException
        }
        setState(
          () {
            _isSigningIn = false;
          },
        );
      },
      child: Container(
        height: 54.sp,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: LivitBarStyle.borderRadius,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 16.sp,
              child: Image.asset(
                'assets/logos/google-logo.png',
                height: 20.sp,
              ),
            ),
            const LivitText(
              'Continuar con Google',
              color: LivitColors.mainBlack,
            ),
            _isSigningIn
                ? Positioned(
                    right: 16.sp,
                    child: SizedBox(
                      height: 13.sp,
                      width: 13.sp,
                      child: const CircularProgressIndicator(
                        color: LivitColors.mainBlack,
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
