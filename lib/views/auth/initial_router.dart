import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/services/auth/bloc/auth_bloc.dart';
import 'package:livit/services/auth/bloc/auth_event.dart';
import 'package:livit/services/auth/bloc/auth_state.dart';
import 'package:livit/utilities/loading_screen.dart';
import 'package:livit/views/auth/login/welcome.dart';
import 'package:livit/views/main_pages/mainmenu.dart';

class InitialRouterView extends StatelessWidget {
  const InitialRouterView({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const MainMenu();
        } else if (state is AuthStateLoggedOut) {
          return const AuthWelcomeView();
        }
        return const LoadingScreenWithBackground();
      },
    );
  }
}
