import 'package:flutter/material.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/services/auth/auth_service.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/buttons/main_action_button.dart';
import 'package:livit/utilities/buttons/secondary_action_button.dart';
import 'package:livit/utilities/dialogs/generic_dialog.dart';
import 'package:livit/utilities/dialogs/show_dialog_2t_2b.dart';

Future<bool> showLogOutDialog({required BuildContext context}) {
  return showGenericDialog<bool>(
    context: context,
    title: '¿Deseas cerrar sesión?',
    content:
        'Tendras que volver a ingresar con tu cuenta para seguir usando Livit',
    optionBuilder: () => {
      'Cancelar': {
        'return': false,
        'buttonType': ButtonType.secondary,
      },
      'Cerrar sesión': {
        'return': true,
        'buttonType': ButtonType.redText,
      },
    },
  ).then((value) => value ?? false);
}
// class LogOutDialog extends StatelessWidget {
//   final BuildContext context;
//   const LogOutDialog({
//     super.key,
//     required this.context,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return MainActionButton(
//       text: 'Cerrar sesión',
//       isActive: true,
//       onPressed: () {
//         showDialog2b(
//           contextList: [null, context],
//           title: '¿Deseas cerrar sesión?',
//           body:
//               'Tendras que volver a ingresar con tu cuenta para seguir usando Livit.',
//           button1: MainActionButton(
//             text: 'Cancelar',
//             isActive: true,
//             onPressed: () {
//               Navigator.of(context).pop(false);
//             },
//           ),
//           button2: SecondaryActionButton(
//             bold: true,
//             activeTextColor: Colors.red,
//             isShadowActive: false,
//             text: 'Cerrar sesión',
//             isActive: true,
//             onPressed: () async {
//               await AuthService.firebase().logOut();
//               if (context.mounted) {
//                 Navigator.of(context).pushNamedAndRemoveUntil(
//                     Routes.authRoute, (route) => false);
//               }
//             },
//           ),
//         );
//       },
//     );
//   }
// }

