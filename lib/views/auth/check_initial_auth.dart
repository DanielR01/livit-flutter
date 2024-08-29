import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/services/auth/auth_service.dart';

class CheckInitialAuth extends StatefulWidget {
  const CheckInitialAuth({super.key});

  @override
  State<CheckInitialAuth> createState() => _CheckInitialAuthState();
}

class _CheckInitialAuthState extends State<CheckInitialAuth> {
  late bool isAuth;
  late bool isLoggedIn;

  @override
  void initState() {
    isAuth = _checkIfLoggedIn();
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _routeUser();
    });
  }

  void _routeUser() {
    if (isAuth) {
      Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.getOrCreateUserRoute, (route) => false);
    } else {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(Routes.welcomeRoute, (route) => false);
    }
  }

  bool _checkIfLoggedIn() {
    final user = AuthService.firebase().currentUser;
    if (user?.id == null) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
