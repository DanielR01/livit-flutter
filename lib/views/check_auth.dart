import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:livit/constants/routes.dart';

class CheckInitialAuth extends StatefulWidget {
  const CheckInitialAuth({super.key});

  @override
  State<CheckInitialAuth> createState() => _CheckInitialAuthState();
}

class _CheckInitialAuthState extends State<CheckInitialAuth> {
  bool isAuth = false;
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
          .pushNamedAndRemoveUntil(feedRoute, (route) => false);
    } else {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(loginRoute, (route) => false);
    }
  }

  bool _checkIfLoggedIn() {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.emailVerified ?? false) {
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
