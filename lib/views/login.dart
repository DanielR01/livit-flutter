import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/utilities/main_action_button.dart';
import 'package:livit/utilities/secondary_action_button.dart';
import 'package:livit/utilities/signin_google.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final double? buttonWidth = 250;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 0),
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
                  width: buttonWidth,
                ),
                const SizedBox(
                  height: 4,
                ),
                MainActionButton(
                  text: 'Continue with phone number',
                  isActive: true,
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(authNumberRoute, arguments: true);
                  },
                  width: buttonWidth,
                ),
                const SizedBox(
                  height: 4,
                ),
                MainActionButton(
                  text: 'Continue with Google',
                  isActive: true,
                  onPressed: () => signInWithGoogle(
                    context,
                    scaffoldKey,
                  ),
                  width: buttonWidth,
                ),
                const SizedBox(
                  height: 4,
                ),
                MainActionButton(
                  text: 'Continue with Apple',
                  isActive: true,
                  width: buttonWidth,
                  onPressed: () {},
                ),
                const SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    const SizedBox(
                      width: 10,
                    ),
                    SecondaryActionButton(
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
