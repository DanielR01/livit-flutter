import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/services/auth/bloc/auth_bloc.dart';
import 'package:livit/services/auth/bloc/auth_event.dart';
import 'package:livit/utilities/buttons/button.dart';

class ErrorReauthScreen extends StatefulWidget {
  const ErrorReauthScreen({super.key});

  @override
  State<ErrorReauthScreen> createState() => _ErrorReauthScreenState();
}

class _ErrorReauthScreenState extends State<ErrorReauthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const LivitText(
                    'Algo salio mal :(',
                    textStyle: TextType.bigTitle,
                  ),
                  LivitSpaces.s,
                  const LivitText('Intenta iniciar sesión de nuevo en unos momentos'),
                  LivitSpaces.l,
                  Button.main(
                    text: 'Volver a iniciar sesión',
                    isActive: true,
                    onPressed: () async {
                      //TODO await AuthService.firebase().logOut();
                      //Navigator.of(context).pushNamedAndRemoveUntil(Routes.welcomeRoute, (route) => false);
                      context.read<AuthBloc>().add(const AuthEventLogOut());
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
