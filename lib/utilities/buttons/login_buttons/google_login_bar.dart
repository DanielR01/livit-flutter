import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/user_types.dart';
import 'package:livit/services/auth/bloc/auth_bloc.dart';
import 'package:livit/services/auth/bloc/auth_event.dart';
import 'package:livit/services/auth/auth_exceptions.dart';

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
          context.read<AuthBloc>().add(const AuthEventLogInWithGoogle());
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
