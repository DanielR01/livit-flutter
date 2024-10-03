import 'package:flutter/material.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogOutDialog({required BuildContext context}) {
  return showGenericDialog<bool>(
    context: context,
    title: '¿Deseas cerrar sesión?',
    content: 'Tendras que volver a ingresar con tu cuenta para seguir usando Livit',
    optionBuilder: () => {
      'Cancelar': {
        'return': false,
        'buttonType': ButtonType.main,
      },
      'Cerrar sesión': {
        'return': true,
        'buttonType': ButtonType.redText,
      },
    },
  ).then((value) => value ?? false);
}
