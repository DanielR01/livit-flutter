import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/services/auth/bloc/auth_bloc.dart';
import 'package:livit/services/auth/bloc/auth_event.dart';
import 'package:livit/services/auth/bloc/auth_state.dart';
import 'package:livit/utilities/loading_screen.dart';
import 'package:livit/views/auth/get_or_create_user/get_or_create_user.dart';
import 'package:livit/views/auth/login/welcome.dart';

class InitialRouterView extends StatelessWidget {
  const InitialRouterView({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return  GetOrCreateUserView(userType: state.userType);
        } else if (state is AuthStateLoggedOut) {
          return const WelcomeView();
        }
        return const LoadingScreenWithBackground();
      },
    );
  }
}
