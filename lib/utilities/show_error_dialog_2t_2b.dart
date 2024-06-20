import 'package:flutter/material.dart';
//import 'dart:developer' as devtools show log;

showErrorDialog2b(GlobalKey contextKey, String title, String body,
    String button, String route) {
  BuildContext? context = contextKey.currentContext;
  if ((context != null) && (context.mounted)) {
    //devtools.log('Mounting dialog');
    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(title: Text(title), content: Text(body), actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Try again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                route,
                (route) => false,
              );
            },
            child: Text(button),
          ),
        ]);
      },
    );
  } else {
    //devtools.log('Not mounted parent');
  }
}
