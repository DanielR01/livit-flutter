import 'package:flutter/material.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/services/auth/auth_service.dart';
import 'package:livit/services/crud/tables/users/user.dart';
import 'package:livit/utilities/background/main_background.dart';
import 'package:livit/utilities/buttons/action_button.dart';
import 'package:livit/utilities/error_dialogs/show_error_dialog_2t_2b.dart';

class ProfileView extends StatefulWidget {
  final LivitUser? user;
  const ProfileView({
    super.key,
    required this.user,
  });

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
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
              LogOutButton(
                context: context,
              ),
              LivitSpaces.medium16spacer,
              MainActionButton(
                text: 'Crear un nuevo evento',
                isActive: true,
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    Routes.newEventRoute,
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

class LogOutButton extends StatelessWidget {
  final BuildContext context;
  const LogOutButton({
    super.key,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return MainActionButton(
      text: 'Cerrar sesión',
      isActive: true,
      onPressed: () {
        showErrorDialog2b(
          [null, context],
          '¿Deseas cerrar sesión?',
          'Tendras que volver a ingresar con tu cuenta para seguir usando Livit.',
          [
            'Cancelar',
            () {
              Navigator.of(context).pop(false);
            },
          ],
          [
            'Cerrar sesión',
            () async {
              await AuthService.firebase().logOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    Routes.authRoute, (route) => false);
              }
            },
          ],
        );
      },
    );
  }
}
