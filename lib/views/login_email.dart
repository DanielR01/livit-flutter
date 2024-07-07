import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/utilities/main_action_button.dart';

import 'package:livit/utilities/show_error_dialog_2t_1b.dart';
import 'package:livit/utilities/show_error_dialog_2t_2b.dart';

class LoginEmailView extends StatefulWidget {
  const LoginEmailView({
    super.key,
  });

  @override
  State<LoginEmailView> createState() => _LoginEmailViewState();
}

class _LoginEmailViewState extends State<LoginEmailView> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  late final TextEditingController _emailFieldController;
  late final TextEditingController _passwordFieldController;

  bool _isEmailValid = false;
  bool _isPasswordValid = false;

  @override
  void initState() {
    _emailFieldController = TextEditingController();
    _passwordFieldController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailFieldController.dispose();
    _passwordFieldController.dispose();
    super.dispose();
  }

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
                  'Log in',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: LivitColors.whiteActive,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text('Log in with your email and password'),
                const SizedBox(
                  height: 40,
                ),
                TextFormField(
                  cursorColor: LivitColors.whiteInactive,
                  controller: _emailFieldController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    setState(
                      () {
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(_emailFieldController.text)) {
                          _isEmailValid = false;
                        } else {
                          _isEmailValid = true;
                        }
                      },
                    );
                  },
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: const TextStyle(
                      color: LivitColors.borderGray,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: LivitColors.borderGray,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: LivitColors.whiteActive),
                    ),
                    suffixIcon: _isEmailValid
                        ? const Icon(
                            Icons.done,
                            color: Color.fromARGB(255, 255, 255, 255),
                            size: 18,
                          )
                        : null,
                  ),
                  style: const TextStyle(
                    color: LivitColors.whiteActive,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  cursorColor: LivitColors.whiteInactive,
                  controller: _passwordFieldController,
                  onChanged: (value) {
                    setState(
                      () {
                        if (_passwordFieldController.text.length < 8 ||
                            _passwordFieldController.text.length > 20) {
                          _isPasswordValid = false;
                        } else {
                          _isPasswordValid = true;
                        }
                      },
                    );
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: const TextStyle(
                      color: LivitColors.borderGray,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: LivitColors.borderGray,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: LivitColors.whiteActive),
                    ),
                    suffixIcon: _isPasswordValid
                        ? const Icon(
                            Icons.done,
                            color: Color.fromARGB(255, 255, 255, 255),
                            size: 18,
                          )
                        : null,
                  ),
                  style: const TextStyle(
                    color: LivitColors.whiteActive,
                  ),
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Password must have at least 8 characters (20 max)',
                  style: TextStyle(
                    color: LivitColors.borderGray,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                MainActionButton(
                  isActive: (_isEmailValid & _isPasswordValid) ? true : false,
                  onPressed: () async {
                    final email = _emailFieldController.text;
                    final password = _passwordFieldController.text;
                    logInWithEmailAndPassword(
                      scaffoldKey,
                      context,
                      email,
                      password,
                    );
                  },
                  text: 'Log in',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void logInWithEmailAndPassword(
    GlobalKey key, BuildContext context, email, String password) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    //print(userCredential);
    final emailVerified =
        FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    if (!emailVerified) {
      if (context.mounted) {
        await Navigator.of(context).pushNamed(
          verifyEmailRoute,
        );
      }
    } else {
      if (context.mounted) {
        await Navigator.of(context)
            .pushNamedAndRemoveUntil(mainviewRoute, (route) => false);
      }
    }
  } on FirebaseAuthException catch (error) {
    switch (error.code) {
      case 'invalid-credential':
        showErrorDialog2b(
          [key, null],
          'Invalid email or password',
          'Check if your email and password are correct or try creating an account',
          [
            'Try Again',
            () {
              Navigator.of(context).pop(false);
            },
          ],
          [
            'Create an account',
            () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(registerRoute, (route) => false);
            },
          ],
        );
        break;
      case 'too-many-requests':
        showErrorDialog(
          key,
          'Too many requests',
          'Try again in a few minutes',
        );
        break;
      default:
        showErrorDialog(
          key,
          'Something went wrong',
          'Error: ${error.code}, Try again in a few minutes',
        );
        break;
    }
  } catch (error) {
    showErrorDialog(
      key,
      'Something went wrong',
      'Error: ${error.toString()}',
    );
  }
}
