import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:livit/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteEventDialog({required BuildContext context}) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Eliminar evento',
    content:
        '¿Estas seguro que deseas continuar?. Esta acción no puede retrocederse luego.',
    optionBuilder: () => {
      'Cancelar': false,
      'Eliminar': true,
    },
  ).then((value) => value ?? false);
}
