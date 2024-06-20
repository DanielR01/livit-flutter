import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:livit/constants/routes.dart';

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
    return Scaffold(
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
                final userCredential =
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                Navigator.of(context).pushNamedAndRemoveUntil(
                  verifyEmailRoute,
                  (route) => false,
                );
              } on FirebaseAuthException catch (error) {
                if (error.code == 'email-already-in-use') {
                  await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                          title: const Text('Email already in use'),
                          content: const Text(
                              'This email is already in use by an account'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: const Text('Try again'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/login/',
                                  (route) => false,
                                );
                              },
                              child: const Text('Log in'),
                            ),
                          ]);
                    },
                  );
                } else if (error.code == 'weak-password') {
                  await showCustomDialog(context, 'Weak password',
                      'The password must have at least 8 characters');
                } else if (error.code == "invalid-email") {
                  await showCustomDialog(context, 'Invalid email',
                      'The email provided is not a valid one');
                } else {
                  await showCustomDialog(
                      context, 'Something went wrong', error.code);
                }
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

Future<bool> showCustomDialog(BuildContext context, String title, String body) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(title: Text(title), content: Text(body), actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('Try again'),
        ),
      ]);
    },
  ).then((value) => value ?? false);
}
