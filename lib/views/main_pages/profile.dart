import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/services/auth/bloc/auth_bloc.dart';
import 'package:livit/services/auth/bloc/auth_event.dart';
import 'package:livit/utilities/background/main_background.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/dialogs/log_out_dialog.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({
    super.key,
  });

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  void _handleLogOut() {
    context.read<AuthBloc>().add(const AuthEventLogOut());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const MainBackground(),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
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
              LivitSpaces.m,
              Button.main(
                text: 'Crear un nuevo evento',
                isActive: true,
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    Routes.createUpdateEventRoute,
                  );
                },
              )
            ],
          ),
        )
      ],
    );
  }
}
