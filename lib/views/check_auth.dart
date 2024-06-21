import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:livit/views/feed.dart';
import 'package:livit/views/login.dart';
import 'dart:developer' as devtools show log;

import 'package:livit/views/login_number.dart';

class CheckAuth extends StatefulWidget {
  @override
  _CheckAuthState createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  bool isAuth = false;
  late Future<bool> loginCheckFuture;

  @override
  void initState() {
    super.initState();
    loginCheckFuture = _checkIfLoggedIn();
  }

  Future<bool> _checkIfLoggedIn() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.emailVerified ?? false) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    return FutureBuilder(
        future: loginCheckFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == true) {
              child = const FeedView();
            } else {
              child = const LoginNumberView();
            }
          } else {
            // future hasnt completed yet
            child = Container();
          }

          return Scaffold(
            body: child,
          );
        });
  }
}
