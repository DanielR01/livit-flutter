import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/services/auth/auth_service.dart';
import 'package:livit/services/crud/tables/users/user.dart';
import 'package:livit/utilities/background/main_background.dart';
import 'package:livit/utilities/buttons/main_action_button.dart';
import 'package:livit/utilities/buttons/secondary_action_button.dart';
import 'package:livit/utilities/dialogs/log_out_dialog.dart';
import 'package:livit/utilities/dialogs/show_dialog_2t_2b.dart';

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
              MainActionButton(
                text: 'Cerrar sesión',
                isActive: true,
                onPressed: () {},
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
