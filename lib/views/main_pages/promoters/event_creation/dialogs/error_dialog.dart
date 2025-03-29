import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';

void showErrorDialog(BuildContext context, String error, {String? title}) {
  showDialog(
    barrierColor: LivitColors.mainBlackDialog,
    context: context,
    builder: (context) {
      late String errorMessage;
      switch (error) {
        case 'Date start time is after end time':
          errorMessage = 'Verifica las fechas de tu evento, el dia y hora de inicio deben ser antes de la fecha de fin';
          break;
        case 'Date start time is before current date':
          errorMessage = 'Verifica las fechas de tu evento, el dia y hora de inicio deben ser despues de la fecha y hora actuales';
          break;
        case 'No location found for date':
          errorMessage =
              'Todas las fechas deben tener una ubicación asignada. Este mensaje puede significar que hay un error, intenta crear el evento de nuevo';
          break;
        case 'No ticket type found for date':
          errorMessage = 'Todas las fechas deben tener un tipo de ticket asignado. Verifica que hayas creado al menos un ticket por fecha';
          break;
        case 'Media file path is null':
          errorMessage = 'Hay un error con tus archivos de multimedia, intenta eliminarlos y agregarlos de nuevo';
          break;
        case 'Media file does not exist':
          errorMessage = 'Hay un error con tus archivos de multimedia, intenta eliminarlos y agregarlos de nuevo';
          break;
        case 'Media file is too large':
          errorMessage = 'Algunos de tus archivos de multimedia son demasiado grandes, intenta reducir su tamaño';
          break;
        case 'Video media cover file path is null':
          errorMessage = 'Hay un error con tus archivos de multimedia, intenta eliminarlos y agregarlos de nuevo';
          break;
        case 'Event media count is greater than 7':
          errorMessage = 'No puedes agregar mas de 7 archivos de multimedia';
          break;
        case 'Ticket type valid time slots end time is before start time':
          errorMessage =
              'Verifica los periodos de validez de tus tickets, el dia y hora de inicio de validez deben ser antes de la fecha de fin de validez';
          break;
        case 'Ticket type valid time slots start time is before current date':
          errorMessage =
              'Verifica los periodos de validez de tus tickets, el dia y hora de inicio de validez deben ser despues de la fecha actual';
          break;
        case 'Ticket type valid time slot start time is after date start time':
          errorMessage =
              'Verifica los periodos de validez de tus tickets, el dia y hora de inicio de validez deben ser antes del dia y hora de inicio de la fecha asociada.\n Es decir, si la fecha de inicio del evento es el 1 de enero a las 9 PM, los tiquetes relacionados con esta fecha deben ser validos antes del 1 de enero a las 9 PM';
          break;
        case 'Ticket type valid time slot end time is after date end time':
          errorMessage =
              'Verifica los periodos de validez de tus tickets, el dia y hora de fin de validez deben ser antes del dia y hora de fin de la fecha asociada.\n Es decir, si la fecha de fin del evento es el 1 de enero a las 9 PM, los tiquetes relacionados con esta fecha deben ser validos hasta el 1 de enero a las 9 PM.';
          break;

        default:
          errorMessage = error;
      }
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LivitBar(
              shadowType: ShadowType.normal,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.exclamationmark_circle,
                      color: LivitColors.yellowError,
                      size: LivitButtonStyle.iconSize,
                    ),
                    LivitSpaces.xs,
                    LivitText(title ?? 'Hay errores en el evento', textType: LivitTextType.smallTitle),
                  ],
                ),
              ),
            ),
            LivitSpaces.m,
            LivitBar(
              shadowType: ShadowType.weak,
              child: Center(
                child: LivitText(
                  errorMessage,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
