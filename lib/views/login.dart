import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/utilities/buttons/main_action_button.dart';
import 'package:livit/utilities/buttons/secondary_action_button.dart';
import 'package:livit/utilities/sign_in/signin_google.dart';

class LoginView extends StatefulWidget {
  final ValueChanged<int> goToRegisterCallback;
  const LoginView({
    super.key,
    required this.goToRegisterCallback,
  });

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final double? buttonWidth = 250;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: LivitContainerStyle.decoration,
      child: Padding(
        padding: LivitContainerStyle.padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
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
                Navigator.of(context).pushNamed(Routes.loginEmailRoute);
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
                    .pushNamed(Routes.authNumberRoute, arguments: true);
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
              mainAxisSize: MainAxisSize.min,
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
                    widget.goToRegisterCallback(1);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
