import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/firebase_options.dart';
import 'package:livit/views/check_auth.dart';
import 'package:livit/views/feed.dart';
import 'package:livit/views/register.dart';
import 'package:livit/views/login.dart';
import 'package:livit/views/verify_email.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Livit',
        theme: ThemeData.dark(),
        home: const CheckInitialAuth(),
        routes: {
          loginRoute: (context) => const LoginView(),
          registerRoute: (context) => const RegisterView(),
          verifyEmailRoute: (context) => const VerifyEmailView(),
          feedRoute: (context) => const FeedView(),
        }),
  );
}
