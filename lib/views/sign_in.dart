import 'package:flutter/material.dart';
import 'package:livit/utilities/bars_containers_fields/login_methods_list.dart';
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
  String phoneNumber = '';
  String verificationId = '';

  void onPhoneLoginPressed(List<String> credentials) {
    setState(
      () {
        phoneNumber = credentials[0];
        verificationId = credentials[1];
        actualIndex = 1;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: actualIndex,
      children: [
        LoginMethodsList(
          scaffoldKey: widget.scaffoldKey,
          phoneLoginCallback: onPhoneLoginPressed,
        ),
        ConfirmOTPCode(
          phoneNumber: phoneNumber,
          verificationId: verificationId,
          onBack: (value) {
            setState(
              () {
                actualIndex = 0;
              },
            );
          },
        ),
      ],
    );
  }
}
