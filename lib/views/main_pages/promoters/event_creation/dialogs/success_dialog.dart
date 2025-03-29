part of '../event_creation.dart';

void _showSuccessDialog(BuildContext context, String eventId) {
  showDialog(
    context: context,
    barrierColor: LivitColors.mainBlackDialog,
    barrierDismissible: false,
    builder: (context) {
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
                    LivitText('¡Evento creado exitosamente!', textType: LivitTextType.smallTitle),
                  ],
                ),
              ),
            ),
            LivitSpaces.m,
            LivitBar(
              noPadding: true,
              shadowType: ShadowType.weak,
              child: Padding(
                padding: LivitContainerStyle.padding(),
                child: Column(
                  children: [
                    LivitText(
                      'Tu evento ha sido creado correctamente. Ahora subiremos los archivos multimedia, espera un momento.',
                    ),
                    LivitSpaces.s,
                    CupertinoActivityIndicator(
                      color: LivitColors.whiteActive,
                      radius: LivitButtonStyle.bigIconSize / 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
