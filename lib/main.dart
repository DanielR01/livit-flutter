import 'dart:io';
import 'dart:ui';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/firebase_options.dart';
import 'package:livit/services/auth/bloc/auth_bloc.dart';
import 'package:livit/services/auth/firebase_auth_provider.dart';
import 'package:livit/services/background/background_events.dart';
import 'package:livit/services/error_reporting/error_reporter.dart';
import 'package:livit/services/files/file_cleanup_manager.dart';
import 'package:livit/services/files/file_cleanup_service.dart';
import 'package:livit/services/files/storage_monitor.dart';
import 'package:livit/services/files/temp_file_manager.dart';
import 'package:livit/services/firebase_storage/bloc/storage_bloc.dart';
import 'package:livit/services/firebase_storage/storage_service/storage_service.dart';
import 'package:livit/services/firestore_storage/bloc/event/event_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/product/product_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/scanner/scanner_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/schedule/schedule_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/ticket/ticket_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/user/user_bloc.dart';
import 'package:livit/services/cloud_functions/firestore_cloud_functions.dart';
import 'package:livit/services/firestore_storage/firestore_storage/firestore_storage.dart';
import 'package:livit/services/navigation/navigation_service.dart';
import 'package:livit/utilities/navigation/transitions/rootwidget.dart';
import 'package:livit/services/background/background_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      name: 'Livit',
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Enable Crashlytics and add debug prints
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  debugPrint('Crashlytics enabled: ${FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled}');

  final errorReporter = ErrorReporter(viewName: 'Main');

  // Catch Flutter errors
  FlutterError.onError = (FlutterErrorDetails details) {
    errorReporter.reportError(
      details.exception,
      details.stack,
      reason: details.context?.toString(),
    );
  };

  // Catch async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    errorReporter.reportError(error, stack);
    return true;
  };

  // Start periodic cleanup
  FileCleanupManager().startPeriodicCleanup();
  StorageMonitor().startPeriodicMonitoring();
  TempFileManager.startPeriodicCleanup();
  FileCleanupService().cleanupTempFiles();
  StorageMonitor.getStorageInfo();

  await initializeAppCheck();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((value) => runApp(
        BlocProvider(
          create: (context) => BackgroundBloc(),
          child: _StartPage(),
        ),
      ));
}

Future<void> initializeAppCheck() async {
  try {
    if (Platform.isIOS) {
      await _initializeIOSAppCheck();
    } else if (Platform.isAndroid) {
      await _initializeAndroidAppCheck();
    }
  } catch (e) {
    debugPrint('❌ [Main] Error initializing App Check: $e');
    if (kDebugMode) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
    }
  }
}

Future<void> _initializeIOSAppCheck() async {
  debugPrint('✅ [Main] Initializing iOS App Check');
  if (kDebugMode) {
    await FirebaseAppCheck.instance.activate(
      appleProvider: AppleProvider.debug,
    );
    debugPrint('✅ [Main] iOS App Check initialized successfully (debug mode)');
    return;
  }
  try {
    await FirebaseAppCheck.instance.activate(
      appleProvider: AppleProvider.appAttestWithDeviceCheckFallback,
    );
    debugPrint('✅ [Main] iOS App Check initialized successfully');
  } catch (e) {
    debugPrint('❌ [Main] Error initializing iOS App Check: $e');
    rethrow;
  }
}

Future<void> _initializeAndroidAppCheck() async {
  debugPrint('✅ [Main] Initializing Android App Check');
  if (kDebugMode) {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
    );
    debugPrint('✅ [Main] Android App Check initialized successfully (debug mode)');
    return;
  }

  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
    );
    debugPrint('✅ [Main] Android App Check initialized successfully');
  } catch (e) {
    debugPrint('❌ [Main] Error initializing Android App Check: $e');
    rethrow;
  }
}

class _StartPage extends StatefulWidget {
  @override
  State<_StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<_StartPage> with WidgetsBindingObserver {
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
      debugPrint('App paused');
      FileCleanupManager().cleanupOnAppPause();
      context.read<BackgroundBloc>().add(BackgroundStopLoadingAnimation(overrideLock: true));
    } else if (state == AppLifecycleState.resumed) {
      debugPrint('App resumed');
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(390, 844));

    debugPrint('🗑️ [Main] Cleaning up old files');
    TempFileManager.cleanupAllFiles();

    return MultiBlocProvider(
      providers: [
        BlocProvider<UserBloc>(
          create: (context) => UserBloc(
            cloudStorage: FirestoreStorageService(),
            firestoreCloudFunctions: FirestoreCloudFunctions(),
            authProvider: FirebaseAuthProvider(),
            backgroundBloc: context.read<BackgroundBloc>(),
          ),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            provider: FirebaseAuthProvider(),
          ),
        ),
        BlocProvider<StorageBloc>(
          create: (context) => StorageBloc(
            storageService: StorageService(),
            cloudFunctions: FirestoreCloudFunctions(),
          ),
        ),
        BlocProvider<LocationBloc>(
          create: (context) => LocationBloc(
            firestoreStorage: FirestoreStorageService(),
            cloudFunctions: FirestoreCloudFunctions(),
            storageBloc: context.read<StorageBloc>(),
            backgroundBloc: context.read<BackgroundBloc>(),
            userBloc: context.read<UserBloc>(),
          ),
        ),
        BlocProvider<EventsBloc>(
          create: (context) => EventsBloc(
            storageService: FirestoreStorageService(),
            locationBloc: context.read<LocationBloc>(),
            backgroundBloc: context.read<BackgroundBloc>(),
          ),
        ),
        BlocProvider<TicketBloc>(
          create: (context) => TicketBloc(
            firestoreStorage: FirestoreStorageService(),
            locationBloc: context.read<LocationBloc>(),
            userBloc: context.read<UserBloc>(),
            backgroundBloc: context.read<BackgroundBloc>(),
          ),
        ),
        BlocProvider<ProductBloc>(
          create: (context) => ProductBloc(
            firestoreStorageService: FirestoreStorageService(),
          ),
        ),
        BlocProvider<ScheduleBloc>(
          create: (context) => ScheduleBloc(
            firestoreStorageService: FirestoreStorageService(),
            locationBloc: context.read<LocationBloc>(),
          ),
        ),
        BlocProvider<ScannerBloc>(
          create: (context) => ScannerBloc(
            cloudFunctions: FirestoreCloudFunctions(),
            errorReporter: ErrorReporter(),
            userBloc: context.read<UserBloc>(),
            firestoreStorageService: FirestoreStorageService(),
          ),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
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
