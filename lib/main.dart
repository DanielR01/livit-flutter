import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
import 'package:livit/services/files/storage_monitor.dart';
import 'package:livit/services/firebase_storage/bloc/storage_bloc.dart';
import 'package:livit/services/firebase_storage/storage_service.dart';
import 'package:livit/services/firestore_storage/bloc/locations/location_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/users/user_bloc.dart';
import 'package:livit/services/firestore_storage/cloud_functions/firestore_cloud_functions.dart';
import 'package:livit/services/firestore_storage/firestore_storage/firestore_storage.dart';
import 'package:livit/services/navigation/navigation_service.dart';
import 'package:livit/utilities/navigation/transitions/rootwidget.dart';
import 'package:livit/services/background/background_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable Crashlytics and add debug prints
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  debugPrint('Crashlytics enabled: ${FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled}');

  final errorReporter = ErrorReporter();

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

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((value) => runApp(
        BlocProvider(
          create: (context) => BackgroundBloc(),
          child: _StartPage(),
        ),
      ));
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
      context.read<BackgroundBloc>().add(BackgroundStopLoadingAnimation());
    } else if (state == AppLifecycleState.resumed) {
      debugPrint('App resumed');
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
            firestoreStorage: FirestoreStorage(),
            cloudFunctions: FirestoreCloudFunctions(),
            storageBloc: context.read<StorageBloc>(),
            backgroundBloc: context.read<BackgroundBloc>(),
            userBloc: context.read<UserBloc>(),
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

// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:inview_notifier_list/inview_notifier_list.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:video_player/video_player.dart';

// class VideoWidget extends StatefulWidget {
//   final String url;
//   final bool play;

//   const VideoWidget({super.key, required this.url, required this.play});

//   @override
//   _VideoWidgetState createState() => _VideoWidgetState();
// }

// class _VideoWidgetState extends State<VideoWidget> {
//   late VideoPlayerController _controller;
//   late Future<void> _initializeVideoPlayerFuture;
//   String? _filePath;

//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
//       final tempDir = await getTemporaryDirectory();
//       _filePath = '${tempDir.path}/compressed_26_12_2024_15_2_1735243367997.mp4';
//       _controller = VideoPlayerController.file(File(
//           '/var/mobile/Containers/Data/Application/6544FEF5-980F-453C-BB59-424D781D14DE/Library/Caches/compressed_29_12_2024_11_30_1735489835880.mp4'));
//       _initializeVideoPlayerFuture = _controller.initialize().then((_) {
//         setState(() {});
//       });

//       if (widget.play) {
//         _controller.play();
//         _controller.setLooping(true);
//       }
//     });
//   }

//   @override
//   void didUpdateWidget(VideoWidget oldWidget) {
//     if (oldWidget.play != widget.play) {
//       if (widget.play) {
//         _controller.play();
//         _controller.setLooping(true);
//       } else {
//         _controller.pause();
//       }
//     }
//     super.didUpdateWidget(oldWidget);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_filePath != null) {
//       print('filePath: $_filePath');
//       print('file exists: ${File(_filePath!).existsSync()}');
//       return FutureBuilder(
//         future: _initializeVideoPlayerFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             return VideoPlayer(_controller);
//           } else {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//         },
//       );
//     }
//     return const SizedBox();
//   }
// }

// class VideoList extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       fit: StackFit.expand,
//       children: <Widget>[
//         InViewNotifierList(
//           scrollDirection: Axis.vertical,
//           initialInViewIds: ['0'],
//           isInViewPortCondition: (double deltaTop, double deltaBottom, double viewPortDimension) {
//             return deltaTop < (0.5 * viewPortDimension) && deltaBottom > (0.5 * viewPortDimension);
//           },
//           itemCount: 30,
//           builder: (BuildContext context, int index) {
//             return Container(
//               width: double.infinity,
//               height: 300.0,
//               alignment: Alignment.center,
//               margin: EdgeInsets.symmetric(vertical: 50.0),
//               child: LayoutBuilder(
//                 builder: (BuildContext context, BoxConstraints constraints) {
//                   final InViewState? inViewState = InViewNotifierList.of(context);
//                   if (inViewState == null) return const SizedBox();

//                   inViewState.addContext(context: context, id: '$index');
//                   return AnimatedBuilder(
//                     animation: inViewState,
//                     builder: (BuildContext context, Widget? child) {
//                       return Container(
//                         clipBehavior: Clip.hardEdge,
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.red),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: VideoWidget(
//                             play: inViewState.inView('$index'),
//                             url: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'),
//                       );
//                     },
//                   );
//                 },
//               ),
//             );
//           },
//         ),
//         Align(
//           alignment: Alignment.center,
//           child: Container(
//             height: 1.0,
//             color: Colors.redAccent,
//           ),
//         )
//       ],
//     );
//   }
// }

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Expanded(child: VideoList()),
//           ],
//         ),
//       ),
//     );
//   }
// }
