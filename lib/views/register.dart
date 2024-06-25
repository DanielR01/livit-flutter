import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/utilities/main_action_button.dart';
import 'package:livit/utilities/signin_google.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
                    Navigator.of(context).pushNamed(registerEmailRoute);
                  },
                ),
                MainActionButton(
                  text: 'Create an account with phone number',
                  isActive: true,
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(authNumberRoute, arguments: false);
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    const SizedBox(
                      width: 10,
                    ),
                    MainActionButton(
                      text: 'Login',
                      isActive: true,
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            loginRoute, ((route) => false));
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
