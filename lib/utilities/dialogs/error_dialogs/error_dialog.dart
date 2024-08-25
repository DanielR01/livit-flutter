import 'package:flutter/material.dart';
import 'package:livit/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(
    {required BuildContext context, required String text}) {
  return showGenericDialog<void>(
    context: context,
    title: 'An error ocurred',
    content: text,
    optionBuilder: () => {
      'Ok': null,
    },
  );
}
