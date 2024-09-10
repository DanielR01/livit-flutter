import 'package:flutter/material.dart';
import 'package:livit/constants/user_types.dart';
import 'package:livit/utilities/login/login_methods_list.dart';

class AuthView extends StatefulWidget {
  final UserType userType;
  final bool isBack;
  const AuthView({
    super.key,
    required this.userType,
    this.isBack = false,
  });

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LoginMethodsList(userType: widget.userType),
    );
  }
}
