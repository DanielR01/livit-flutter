import 'package:flutter/material.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/services/auth/auth_service.dart';
import 'package:livit/utilities/buttons/main_action_button.dart';
import 'package:livit/utilities/error_dialogs/show_error_dialog_2t_2b.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({
    super.key,
  });

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MainActionButton(
        text: 'Log Out',
        isActive: true,
        onPressed: () {
          showErrorDialog2b(
            [null, context],
            'Log Out',
            'Do you want to log out?',
            [
              'Cancel',
              () {
                Navigator.of(context).pop(false);
              },
            ],
            [
              'Log out',
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
      ),
    );
  }
}
