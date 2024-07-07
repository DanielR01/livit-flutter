import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/utilities/main_action_button.dart';
import 'package:livit/utilities/secondary_action_button.dart';
import 'package:livit/utilities/signin_google.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final double? buttonWidth = 250;

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
                  'Register',
                  style: TextStyle(
                    fontSize: 22,
                    color: LivitColors.whiteActive,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                MainActionButton(
                  text: 'Create an account with email',
                  isActive: true,
                  onPressed: () {
                    Navigator.of(context).pushNamed(Routes.registerEmailRoute);
                  },
                  width: buttonWidth,
                ),
                const SizedBox(
                  height: 4,
                ),
                MainActionButton(
                  text: 'Register with phone number',
                  isActive: true,
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(Routes.authNumberRoute, arguments: false);
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
                    const Text("Already have an account?"),
                    const SizedBox(
                      width: 10,
                    ),
                    SecondaryActionButton(
                      text: 'Log in',
                      isActive: true,
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            Routes.loginRoute, ((route) => false));
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
