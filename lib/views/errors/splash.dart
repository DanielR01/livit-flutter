import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/services/auth/bloc/auth_bloc.dart';
import 'package:livit/services/background/background_bloc.dart';
import 'package:livit/services/firebase_storage/bloc/storage_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/locations/location_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/users/user_bloc.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _reinitialize();
  }

  Future<void> _reinitialize() async {
    debugPrint('🔄 [SplashView] Reinitializing app...');

    try {
      // Reset Firebase
      debugPrint('🔄 [SplashView] Reinitializing Firebase...');
      await Firebase.initializeApp();

      if (!mounted) return;

      // Reset all blocs
      debugPrint('🔄 [SplashView] Resetting blocs...');
      context.read<AuthBloc>().close();
      context.read<UserBloc>().close();
      context.read<LocationBloc>().close();
      context.read<StorageBloc>().close();
      context.read<BackgroundBloc>().close();

      // Navigate to initial router
      debugPrint('✅ [SplashView] Reinitialization complete, navigating to initial router');
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('❌ [SplashView] Error during reinitialization: $e');
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
