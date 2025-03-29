part of '../event_creation.dart';

void _showLoadingDialog(BuildContext context) {
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
                    LivitText('Creando evento', textType: LivitTextType.smallTitle),
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
                      'Por favor espera mientras creamos tu evento. No cierres esta pantalla.',
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
