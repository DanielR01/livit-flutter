import 'package:flutter/material.dart';
import 'package:livit/utilities/sign_in/login_methods_list.dart';
import 'package:livit/utilities/sign_in/confirm_otp_code.dart';

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
  int actualIndex = 0;
  String phoneCode = '';
  String phoneNumber = '';
  String verificationId = '';

  void onPhoneLoginPressed(List<String> credentials) {
    setState(
      () {
        phoneCode = credentials[0];
        phoneNumber = credentials[1];
        verificationId = credentials[2];
        actualIndex = 1;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (actualIndex == 0) {
      return LoginMethodsList(
        scaffoldKey: widget.scaffoldKey,
        phoneLoginCallback: onPhoneLoginPressed,
      );
    } else {
      return ConfirmOTPCode(
        phoneCode: phoneCode,
        phoneNumber: phoneNumber,
        initialVerificationId: verificationId,
        onBack: (value) {
          setState(
            () {
              actualIndex = 0;
            },
          );
        },
      );
    }
  }
}
