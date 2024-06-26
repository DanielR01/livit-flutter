import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
//import 'dart:developer' as devtools show log;

showErrorDialog2b(GlobalKey contextKey, String title, String body,
    String buttonText, String route) {
  BuildContext? context = contextKey.currentContext;
  if ((context != null) && (context.mounted)) {
    //devtools.log('Mounting dialog');
    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: LivitColors.mainBlack,
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Try again',
                style: TextStyle(
                  color: LivitColors.mainBlueActive,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  route,
                  (route) => false,
                );
              },
              child: Text(
                buttonText,
                style: const TextStyle(
                  color: LivitColors.mainBlueActive,
                ),
              ),
            ),
          ],
          titleTextStyle: const TextStyle(
            color: LivitColors.whiteActive,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: const TextStyle(
            color: LivitColors.whiteActive,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        );
      },
    );
  } else {
    //devtools.log('Not mounted parent');
  }
}
