import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/services/auth/bloc/auth_bloc.dart';
import 'package:livit/services/auth/bloc/auth_event.dart';
import 'package:livit/services/auth/bloc/auth_state.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/views/auth/login/welcome.dart';

class ErrorReauthScreen extends StatefulWidget {
  final Exception? exception;
  const ErrorReauthScreen({super.key, this.exception});

  @override
  State<ErrorReauthScreen> createState() => _ErrorReauthScreenState();
}

class _ErrorReauthScreenState extends State<ErrorReauthScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateLoggedOut) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const WelcomeView()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: LivitContainerStyle.paddingFromScreen,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const LivitText(
                    '¡Ups!',
                    textType: TextType.bigTitle,
                  ),
                  LivitSpaces.xs,
                  const LivitText(
                    'Algo salió mal, intenta iniciar sesión de nuevo.',
                    textAlign: TextAlign.center,
                  ),
                  if (widget.exception != null)
                    LivitText(
                      widget.exception.toString(),
                    ),
                  LivitSpaces.m,
                  Button.main(
                    isActive: true,
                    text: 'Iniciar sesión de nuevo',
                    onPressed: () {
                      context.read<AuthBloc>().add(const AuthEventLogOut());
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
