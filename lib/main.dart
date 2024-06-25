import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/firebase_options.dart';
import 'package:livit/utilities/route_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const StartPage());
}

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Livit',
      theme: ThemeData(
        scaffoldBackgroundColor: LivitColors.mainBlack,
        appBarTheme: const AppBarTheme(
          color: LivitColors.mainBlack,
          titleTextStyle: TextStyle(
            color: LivitColors.whiteActive,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
