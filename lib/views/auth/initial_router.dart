import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/services/auth/bloc/auth_bloc.dart';
import 'package:livit/services/auth/bloc/auth_event.dart';
import 'package:livit/services/auth/bloc/auth_state.dart';
import 'package:livit/services/firestore_storage/bloc/users/user_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/users/user_event.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/buttons/login_buttons/google_login_bar.dart';
import 'package:livit/utilities/dialogs/log_out_dialog.dart';
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
          return GetOrCreateUserView(userType: state.userType);
        } else if (state is AuthStateLoggedOut) {
          return const WelcomeView();
        }
        return const LoadingScreenWithBackground();
      },
    );
  }
}

class TestFirestore extends StatefulWidget {
  const TestFirestore({super.key});

  @override
  State<TestFirestore> createState() => _TestFirestoreState();
}

class _TestFirestoreState extends State<TestFirestore> {
  void _handleLogOut() {
    context.read<AuthBloc>().add(const AuthEventLogOut());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String text;
        if (state is AuthStateLoggedIn) {
          text = 'Logged in as ${state.userType}';
        } else {
          text = 'Logged out';
        }
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                LivitText(text),
                GoogleLoginBar(userType: UserType.customer),
                LivitSpaces.m,
                Button.main(
                  text: 'Create user',
                  isActive: true,
                  onPressed: () {
                    BlocProvider.of<UserBloc>(context).add(
                      CreateUser(
                        name: 'helloWorld',
                        username: 'helloWorld',
                        userType: UserType.customer,
                      ),
                    );
                  },
                ),
                LivitSpaces.m,
                Button.main(
                  text: 'Cerrar sesión',
                  isActive: true,
                  onPressed: () async {
                    final bool shouldLogOut = await showLogOutDialog(context: context);
                    if (shouldLogOut) {
                      _handleLogOut();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
