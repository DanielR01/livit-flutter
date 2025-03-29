part of '../event_creation.dart';

Future<void> _showFinalSuccessDialog(BuildContext context, String eventId) async {
  await showDialog(
    context: context,
    barrierColor: LivitColors.mainBlackDialog,
    barrierDismissible: false,
    builder: (dialogContext) {
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
                    LivitText('¡Proceso completado!', textType: LivitTextType.smallTitle),
                    LivitSpaces.xs,
                    Icon(
                      CupertinoIcons.checkmark_circle,
                      color: LivitColors.mainBlueActive,
                      size: LivitButtonStyle.bigIconSize,
                    ),
                  ],
                ),
              ),
            ),
            LivitSpaces.m,
            LivitBar(
              shadowType: ShadowType.weak,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    LivitText(
                      'Tu evento ha sido creado y sus archivos multimedia han sido subidos correctamente.',
                    ),
                  ],
                ),
              ),
            ),
            LivitSpaces.s,
            Row(
              children: [
                Expanded(
                  child: Button.main(
                    text: 'Aceptar',
                    onTap: () {
                      // Close the dialog first
                      Navigator.of(dialogContext).pop();
                    },
                    isActive: true,
                    rightIcon: CupertinoIcons.checkmark_alt_circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
