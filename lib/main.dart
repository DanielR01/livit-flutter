import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/services/auth/bloc/auth_bloc.dart';
import 'package:livit/services/auth/firebase_auth_provider.dart';
import 'package:livit/services/files/file_cleanup_service.dart';
import 'package:livit/services/files/storage_monitor.dart';
import 'package:livit/services/firebase_storage/bloc/storage_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/locations/location_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/users/user_bloc.dart';
import 'package:livit/services/firestore_storage/cloud_functions/firestore_cloud_functions.dart';
import 'package:livit/services/firestore_storage/firestore_storage/firestore_storage.dart';
import 'package:livit/utilities/transitions/rootwidget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Timer.periodic(const Duration(minutes: 10), (_) {
    FileCleanupService().cleanupTempFiles();
  });

  Timer.periodic(const Duration(minutes: 10), (_) async {
    final sizes = await StorageMonitor.getStorageInfo();
    debugPrint('Storage sizes: $sizes');
  });
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((value) => runApp(StartPage()));
}

class StartPage extends StatefulWidget {
  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> with WidgetsBindingObserver {
  final _navKey = GlobalKey<NavigatorState>(debugLabel: 'navKey');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      FileCleanupService().cleanupTempFiles();
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(390, 844));
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserBloc>(
          create: (context) => UserBloc(
            cloudStorage: FirestoreStorage(),
            firestoreCloudFunctions: FirestoreCloudFunctions(),
            authProvider: FirebaseAuthProvider(),
          ),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            provider: FirebaseAuthProvider(),
          ),
        ),
        BlocProvider<LocationBloc>(
          create: (context) => LocationBloc(),
        ),
        BlocProvider<StorageBloc>(
          create: (context) => StorageBloc(),
        ),
      ],
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
    );
  }
}
