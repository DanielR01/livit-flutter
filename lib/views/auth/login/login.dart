import 'package:flutter/material.dart';
import 'package:livit/services/cloud/firebase_cloud_storage.dart';
import 'package:livit/utilities/background/main_background.dart';
import 'package:livit/utilities/login/login_methods_list.dart';

class LoginView extends StatefulWidget {
  final UserType userType;
  const LoginView({
    super.key,
    required this.userType,
  });

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  String phoneCode = '';
  String phoneNumber = '';
  String verificationId = '';

  void onPhoneLoginPressed(List<String> credentials) {
    setState(
      () {
        phoneCode = credentials[0];
        phoneNumber = credentials[1];
        verificationId = credentials[2];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const MainBackground(),
          LoginMethodsList(
            userType: widget.userType,
          ),
        ],
      ),
    );
  }
}
