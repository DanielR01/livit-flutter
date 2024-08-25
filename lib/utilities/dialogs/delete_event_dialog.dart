import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteEventDialog({required BuildContext context}) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Eliminar evento',
    content:
        '¿Estas seguro que deseas continuar?. Esta acción no puede retrocederse luego.',
    optionBuilder: () => {
      'Cancelar': {
        'return': false,
        'buttonType': ButtonType.main,
      },
      'Eliminar': {
        'return': true,
        'buttonType': ButtonType.redText,
      },
    },
  ).then((value) => value ?? false);
}
