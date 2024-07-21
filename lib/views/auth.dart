import 'package:flutter/material.dart';
import 'package:livit/utilities/background/main_background.dart';
import 'package:livit/views/sign_in.dart';
import 'package:livit/views/welcome.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedIndex = 0;

  void onPressed(index) {
    setState(
      () {
        selectedIndex = index;
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          const MainBackground(),
          SafeArea(
            child: IndexedStack(
              index: selectedIndex,
              children: [
                WelcomeView(
                  goToSignIn: (value) => onPressed(value),
                ),
                // AuthNumberView(isLogin: false),
                SignInView(
                  scaffoldKey: _scaffoldKey,
                  goToRegister: (value) => onPressed(value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
