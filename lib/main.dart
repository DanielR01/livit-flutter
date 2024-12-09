import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/services/auth/bloc/auth_bloc.dart';
import 'package:livit/services/auth/firebase_auth_provider.dart';
import 'package:livit/services/cloud/bloc/users/user_bloc.dart';
import 'package:livit/services/cloud/cloud_functions/firestore_cloud_functions.dart';
import 'package:livit/services/cloud/firebase_cloud_storage.dart';
import 'package:livit/utilities/transitions/rootwidget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((value) => runApp(StartPage()));
}

class StartPage extends StatelessWidget {
  StartPage({super.key});

  final _navKey = GlobalKey<NavigatorState>(debugLabel: 'navKey');

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(390, 844));
    return BlocProvider(
      create: (context) => UserBloc(
        cloudStorage: FirebaseCloudStorage(),
        firestoreCloudFunctions: FirestoreCloudFunctions(),
        authProvider: FirebaseAuthProvider(),
      ),
      child: BlocProvider(
        create: (context) => AuthBloc(
          provider: FirebaseAuthProvider(),
        ),
        child: MaterialApp(
          navigatorKey: _navKey,
          debugShowCheckedModeBanner: false,
          title: 'Livit',
          theme: ThemeData(
            textSelectionTheme: const TextSelectionThemeData(
              selectionColor: LivitColors.whiteInactive,
              selectionHandleColor: LivitColors.whiteActive,
              cursorColor: LivitColors.whiteActive,
            ),
            scaffoldBackgroundColor: Colors.transparent,
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
            scrollbarTheme: ScrollbarThemeData(
              thumbColor: WidgetStateProperty.all(LivitColors.whiteActive),
            ),
          ),
          home: RootWidgetBackground(),
        ),
      ),
    );
  }
}
