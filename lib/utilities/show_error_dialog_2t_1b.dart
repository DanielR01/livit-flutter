import 'package:flutter/material.dart';
//import 'dart:developer' as devtools show log;

showErrorDialog(GlobalKey contextKey, String title, String body) {
  BuildContext? context = contextKey.currentContext;
  if ((context != null) && (context.mounted)) {
    //devtools.log('Mounting dialog');
    return showDialog(
      context: context,
      builder: (contextOfBuilder) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(contextOfBuilder).pop();
              },
              child: const Text('Try again'),
            ),
          ],
        );
      },
    );
  } else {
    //devtools.log('Not mounted parent');
  }
}
