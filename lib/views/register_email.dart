import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/utilities/main_action_button.dart';

import 'package:livit/utilities/show_error_dialog_2t_1b.dart';
import 'package:livit/utilities/show_error_dialog_2t_2b.dart';

class RegisterEmailView extends StatefulWidget {
  const RegisterEmailView({super.key});

  @override
  State<RegisterEmailView> createState() => _RegisterEmailViewState();
}

class _RegisterEmailViewState extends State<RegisterEmailView> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isEmailValid = false;
  bool _isPasswordValid = false;

  late final TextEditingController _emailFieldController;
  late final TextEditingController _passwordFieldController;

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
                  'Register',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: LivitColors.whiteActive,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text('Register with an email and password'),
                const SizedBox(
                  height: 40,
                ),
                TextFormField(
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
                  isActive: (_isEmailValid && _isPasswordValid) ? true : false,
                  onPressed: () async {
                    final email = _emailFieldController.text;
                    final password = _passwordFieldController.text;
                    registerWithEmailAndPassword(
                      context,
                      scaffoldKey,
                      email,
                      password,
                    );
                  },
                  text: 'Register',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void registerWithEmailAndPassword(BuildContext context, GlobalKey key,
      String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        await Navigator.of(context).pushNamed(verifyEmailRoute);
      }
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case 'email-already-in-use':
          await showErrorDialog2b(
            key,
            'Email already in use',
            'This email is already in use by an account',
            'Log in',
            loginEmailRoute,
          );
          break;
        case 'weak-password':
          showErrorDialog(
            key,
            'Weak password',
            'The password must have at least 8 characters',
          );
          break;
        case 'invalid-email':
          showErrorDialog(
            key,
            'Invalid email',
            'The email provided is not a valid one',
          );
          break;
        default:
          showErrorDialog(
            key,
            'Something went wrong',
            'Error: ${error.code}',
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
}
