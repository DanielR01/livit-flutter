import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/constants/styles/text_style.dart';
import 'package:livit/utilities/bars_containers_fields/login_methods_list.dart';
import 'package:livit/utilities/login_bars/apple_login_bar.dart';
import 'package:livit/utilities/login_bars/google_login_bar.dart';
import 'package:livit/utilities/buttons/main_action_button.dart';
import 'package:livit/utilities/bars_containers_fields/text_field.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
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
  String? phoneNumber;

  void onPhoneLoginPressed(String passedPhoneNumber) {
    setState(
      () {
        phoneNumber = passedPhoneNumber;
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
