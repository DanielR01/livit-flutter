import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/utilities/main_action_button.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  text: 'Login with email',
                  isActive: true,
                  onPressed: () {
                    Navigator.of(context).pushNamed(loginEmailRoute);
                  },
                ),
                MainActionButton(
                  text: 'Login with phone number',
                  isActive: true,
                  onPressed: () {
                    Navigator.of(context).pushNamed(loginNumberRoute);
                  },
                ),
                MainActionButton(
                  text: 'Create an account',
                  isActive: true,
                  onPressed: () {
                    Navigator.of(context).pushNamed(registerEmailRoute);
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
