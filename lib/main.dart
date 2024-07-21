import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/services/auth/auth_service.dart';
import 'package:livit/utilities/route_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.firebase().initialize();
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
        textSelectionTheme: const TextSelectionThemeData(
          selectionColor: LivitColors.whiteInactive,
          selectionHandleColor: LivitColors.whiteActive,
          cursorColor: LivitColors.whiteActive,
        ),
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
        fontFamily: 'HelveticaNowDisplay',
      ),
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
