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
                      Icon(
                        CupertinoIcons.checkmark_circle,
                        color: LivitColors.mainBlueActive,
                        size: LivitButtonStyle.iconSize,
                      ),
                      LivitSpaces.xs,
                      LivitText('¡Evento creado exitosamente!', textType: LivitTextType.smallTitle),
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
                        'Tu evento ha sido creado correctamente. Ahora subiremos los archivos multimedia.',
                      ),
                      LivitSpaces.s,
                      Button.main(
                        text: 'Aceptar',
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).pop();
                          Navigator.pop(context);
                        },
                        isActive: true,
                        rightIcon: CupertinoIcons.checkmark_alt_circle,
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
