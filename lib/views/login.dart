import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/utilities/main_action_button.dart';
import 'package:livit/utilities/signin_google.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
            child: Column(
              children: [
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 22,
                    color: LivitColors.whiteActive,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                MainActionButton(
                  text: 'Continue with email',
                  isActive: true,
                  onPressed: () {
                    Navigator.of(context).pushNamed(loginEmailRoute);
                  },
                ),
                MainActionButton(
                  text: 'Continue with phone number',
                  isActive: true,
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(authNumberRoute, arguments: true);
                  },
                ),
                MainActionButton(
                  text: 'Continue with Google',
                  isActive: true,
                  onPressed: () => signInWithGoogle(
                    context,
                    scaffoldKey,
                  ),
                ),
                const MainActionButton(
                  text: 'Continue with Apple',
                  isActive: true,
                ),
                const SizedBox(
                  height: 40,
                ),
                Row(
                  children: [
                    const Text("Don't have an account?"),
                    const SizedBox(
                      width: 10,
                    ),
                    MainActionButton(
                      text: 'Create an account',
                      isActive: true,
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            registerRoute, (route) => false);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
