import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
        title: const Text('Login'),
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
                await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                //print(userCredential);
                final emailVerified =
                    FirebaseAuth.instance.currentUser?.emailVerified ?? false;
                if (!emailVerified) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/verifyemail/',
                    (route) => false,
                  );
                } else {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/feed/',
                    (route) => false,
                  );
                }
              } on FirebaseAuthException catch (e) {
                print(e.code);
                switch (e.code) {
                  case 'invalid-credential':
                    await showCustomDialog(
                      context,
                      'Invalid email or password',
                      'Check if your email and password are correct or try creating an account',
                    );
                    break;
                  case 'too-many-requests':
                    await showCustomDialog(
                      context,
                      'Too many requests',
                      'Try again in a few minutes',
                    );
                    break;
                  default:
                    await showCustomDialog(
                      context,
                      'Something went wrong',
                      'Try again in a few minutes',
                    );
                    break;
                }
              }
            },
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/register/',
                (route) => false,
              );
            },
            child: const Text('Create an account'),
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
