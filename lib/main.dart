import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/firebase_options.dart';
import 'package:livit/utilities/main_background.dart';
import 'package:livit/utilities/route_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(const StartPage()));
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
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            color: LivitColors.whiteActive,
          ),
          bodyMedium: TextStyle(
            color: LivitColors.whiteActive,
          ),
          bodySmall: TextStyle(
            color: LivitColors.whiteActive,
          ),
        ),
      ),
      //initialRoute: '/',
      //onGenerateRoute: RouteGenerator.generateRoute,
      home: MainBackground(),
    );
  }
}
