import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/utilities/main_action_button.dart';
import 'package:livit/utilities/show_error_dialog_2t_2b.dart';

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
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(loginRoute, (route) => false);
                }
              },
            ],
          );
        },
      ),
    );
  }
}
