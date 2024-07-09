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
      Navigator.of(context)
          .pushNamedAndRemoveUntil(Routes.mainviewRoute, (route) => false);
    } else {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(Routes.loginRoute, (route) => false);
    }
  }

  bool _checkIfLoggedIn() {
    final user = AuthService.firebase().currentUser;
    print(user?.isEmailVerified);
    if (user == null) {
      return false;
    } else if (user.isEmailVerified) {
      return true;
    } else if (user.hasPhoneNumber) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
