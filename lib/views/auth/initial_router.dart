import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/services/auth/bloc/auth_bloc.dart';
import 'package:livit/services/auth/bloc/auth_event.dart';
import 'package:livit/services/auth/bloc/auth_state.dart';

class InitialRouterView extends StatelessWidget {
  const InitialRouterView({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('🔄 [InitialRouterView] Building and adding AuthEventInitialize');
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => true,
      listener: (context, state) {
        if (state is AuthStateLoggedIn) {
          debugPrint('🔄 [InitialRouterView] AuthStateLoggedIn');
          Navigator.pushReplacementNamed(
            context,
            Routes.getOrCreateUserRoute,
          );
        } else if (state is AuthStateLoggedOut) {
          debugPrint('🔄 [InitialRouterView] AuthStateLoggedOut');
          Navigator.pushReplacementNamed(
            context,
            Routes.welcomeRoute,
          );
        }
      },
      child: const Scaffold(),
    );
  }
}
