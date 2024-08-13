import 'package:flutter/material.dart';
import 'package:livit/utilities/sign_in/login_methods_list.dart';
import 'package:livit/utilities/sign_in/confirm_otp_code.dart';
import 'package:livit/utilities/sign_in/promoter_auth.dart';

enum SignInViews {
  main,
  confirmPhoneNumber,
  promoterSignIn,
}

class SignInView extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final ValueChanged<int> goToRegister;

  const SignInView({
    super.key,
    required this.scaffoldKey,
    required this.goToRegister,
  });

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  SignInViews actualView = SignInViews.main;
  String phoneCode = '';
  String phoneNumber = '';
  String verificationId = '';

  void onPhoneLoginPressed(List<String> credentials) {
    setState(
      () {
        phoneCode = credentials[0];
        phoneNumber = credentials[1];
        verificationId = credentials[2];
        actualView = SignInViews.confirmPhoneNumber;
      },
    );
  }

  void onPromoterAuthPressed() {
    setState(
      () {
        actualView = SignInViews.promoterSignIn;
      },
    );
  }

  void onBackPressed() {
    setState(
      () {
        actualView = SignInViews.main;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (actualView) {
      case SignInViews.main:
        return LoginMethodsList(
          scaffoldKey: widget.scaffoldKey,
          phoneLoginCallback: onPhoneLoginPressed,
          promoterAuthCallback: onPromoterAuthPressed,
        );
      case SignInViews.confirmPhoneNumber:
        return ConfirmOTPCode(
          phoneCode: phoneCode,
          phoneNumber: phoneNumber,
          initialVerificationId: verificationId,
          onBack: () {
            setState(
              () {
                actualView = SignInViews.main;
              },
            );
          },
        );
      case SignInViews.promoterSignIn:
        return PromoterAuth(
          onBack: onBackPressed,
        );
    }
  }
}
