import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/routes.dart';

import 'package:livit/utilities/show_error_dialog_2t_1b.dart';
import 'package:livit/utilities/show_error_dialog_2t_2b.dart';

class LoginEmailView extends StatefulWidget {
  const LoginEmailView({super.key});

  @override
  State<LoginEmailView> createState() => _LoginEmailViewState();
}

class _LoginEmailViewState extends State<LoginEmailView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _ScaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _ScaffoldKey,
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            decoration: const InputDecoration(
              hintText: 'Enter your email',
              hintStyle: TextStyle(
                color: LivitColors.borderGray,
              ),
            ),
            style: const TextStyle(
              color: LivitColors.whiteActive,
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          TextField(
            controller: _password,
            decoration: const InputDecoration(
              hintText: 'Enter your password',
              hintStyle: TextStyle(
                color: LivitColors.borderGray,
              ),
            ),
            style: const TextStyle(
              color: LivitColors.whiteActive,
            ),
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
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
                    await Navigator.of(context).pushNamed(
                      feedRoute,
                    );
                  }
                }
              } on FirebaseAuthException catch (error) {
                switch (error.code) {
                  case 'invalid-credential':
                    await showErrorDialog2b(
                      _ScaffoldKey,
                      'Invalid email or password',
                      'Check if your email and password are correct or try creating an account',
                      'Create an account',
                      registerEmailRoute,
                    );
                    break;
                  case 'too-many-requests':
                    await showErrorDialog(
                      _ScaffoldKey,
                      'Too many requests',
                      'Try again in a few minutes',
                    );
                    break;
                  default:
                    await showErrorDialog(
                      _ScaffoldKey,
                      'Something went wrong',
                      'Error: ${error.code}, Try again in a few minutes',
                    );
                    break;
                }
              } catch (error) {
                await showErrorDialog(
                  _ScaffoldKey,
                  'Something went wrong',
                  'Error: ${error.toString()}',
                );
              }
            },
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed(
                registerEmailRoute,
              );
            },
            child: const Text('Create an account'),
          ),
        ],
      ),
    );
  }
}
