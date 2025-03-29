  
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
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: LivitColors.mainBlueActive,
                          strokeWidth: 3,
                        ),
                      ),
                      LivitSpaces.xs,
                      LivitText('Creando evento...', textType: LivitTextType.smallTitle),
                    ],
                  ),
                ),
              ),
              LivitSpaces.m,
              LivitBar(
                shadowType: ShadowType.weak,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LivitText(
                    'Por favor espera mientras creamos tu evento. No cierres esta pantalla.',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
