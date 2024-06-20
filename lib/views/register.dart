import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:livit/constants/routes.dart';

import 'package:livit/utilities/show_error_dialog_2t_1b.dart';
import 'package:livit/utilities/show_error_dialog_2t_2b.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
        title: const Text('Register'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            decoration: const InputDecoration(
              hintText: 'Enter your email',
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          TextField(
            controller: _password,
            decoration: const InputDecoration(
              hintText: 'Enter your password',
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
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    verifyEmailRoute,
                    (route) => false,
                  );
                }
              } on FirebaseAuthException catch (error) {
                switch (error.code) {
                  case 'email-already-in-use':
                    showErrorDialog2b(
                      _ScaffoldKey,
                      'Email already in use',
                      'This email is already in use by an account',
                      'Log in',
                      loginRoute,
                    );
                    break;
                  case 'weak-password':
                    showErrorDialog(
                      _ScaffoldKey,
                      'Weak password',
                      'The password must have at least 8 characters',
                    );
                    break;
                  case 'invalid-email':
                    showErrorDialog(
                      _ScaffoldKey,
                      'Invalid email',
                      'The email provided is not a valid one',
                    );
                    break;
                  default:
                    showErrorDialog(
                      _ScaffoldKey,
                      'Something went wrong',
                      'Error: ${error.code}',
                    );
                    break;
                }
              } catch (error) {
                showErrorDialog(
                  _ScaffoldKey,
                  'Something went wrong',
                  'Error: ${error.toString()}',
                );
              }
            },
            child: const Text('Register'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                loginRoute,
                (route) => false,
              );
            },
            child: const Text('Already have an account? Login'),
          ),
        ],
      ),
    );
  }
}
