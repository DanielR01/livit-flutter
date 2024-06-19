import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:livit/firebase_options.dart';
import 'package:livit/views/register.dart';
import 'package:livit/views/login.dart';
import 'package:livit/views/verify_email.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
        title: 'Livit',
        theme: ThemeData.dark(),
        home: const HomePage(),
        routes: {
          '/login/': (context) => const LoginView(),
          '/register/': (context) => const RegisterView(),
          '/verifyemail/': (context) => const VerifyEmailView(),
        }),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: ((context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            // final user = FirebaseAuth.instance.currentUser;
            // print(user);
            // final emailVerified = user?.emailVerified ?? false;
            // if (emailVerified) {
            //   return const Text('Done');
            // } else {
            //   return const VerifyEmailView();
            // }
            return const LoginView();
          default:
            return const Text('Loading');
        }
      }),
    );
  }
}
