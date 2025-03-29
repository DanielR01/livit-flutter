import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/services/auth/bloc/auth_bloc.dart';
import 'package:livit/services/background/background_bloc.dart';
import 'package:livit/services/firebase_storage/bloc/storage_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/user/user_bloc.dart';
import 'package:livit/utilities/debug/livit_debugger.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final _debugger = const LivitDebugger('SplashView');

  @override
  void initState() {
    super.initState();
    _reinitialize();
  }

  Future<void> _reinitialize() async {
    _debugger.debPrint('Reinitializing app...', DebugMessageType.restarting);

    try {
      // Instead of reinitializing Firebase, check if it's initialized
      _debugger.debPrint('Checking Firebase initialization...', DebugMessageType.initializing);
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      } else {
        _debugger.debPrint('Firebase already initialized', DebugMessageType.done);
      }

      if (!mounted) return;

      // Reset all blocs
      _debugger.debPrint('Resetting blocs...', DebugMessageType.restarting);
      context.read<AuthBloc>().close();
      context.read<UserBloc>().close();
      context.read<LocationBloc>().close();
      context.read<StorageBloc>().close();
      context.read<BackgroundBloc>().close();

      // Navigate to initial router
      _debugger.debPrint('Reinitialization complete, navigating to initial router', DebugMessageType.done);
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (route) => false,
        );
      }
    } catch (e) {
      _debugger.debPrint('Error during reinitialization: $e', DebugMessageType.error);
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.welcomeRoute,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
