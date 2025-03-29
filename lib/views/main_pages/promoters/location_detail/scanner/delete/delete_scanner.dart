import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/models/user/cloud_user.dart';
import 'package:livit/services/cloud_functions/firestore_cloud_functions.dart';
import 'package:livit/services/firestore_storage/bloc/scanner/scanner_bloc.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/debug/livit_debugger.dart';

class DeleteScanner {
  final FirestoreCloudFunctions _firestoreCloudFunctions = FirestoreCloudFunctions();
  final _debugger = const LivitDebugger('DeleteScanner');

  Future<bool> _showDeleteConfirmationDialog(BuildContext context, CloudScanner scanner) async {
    bool confirmDelete = false;
    await showDialog(
      context: context,
      barrierColor: LivitColors.mainBlackDialog,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LivitBar(
                shadowType: ShadowType.normal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LivitText('¿Eliminar escáner?', textType: LivitTextType.smallTitle),
                    LivitSpaces.xs,
                    Icon(
                      CupertinoIcons.exclamationmark_triangle,
                      color: LivitColors.whiteActive,
                      size: LivitButtonStyle.bigIconSize,
                    ),
                  ],
                ),
              ),
              LivitSpaces.m,
              Container(
                decoration: LivitContainerStyle.decorationWithInactiveShadow,
                child: Padding(
                  padding: LivitContainerStyle.padding(),
                  child: Column(
                    children: [
                      LivitText(
                        'Esta acción eliminará permanentemente el escáner "${scanner.name}" junto con sus datos y registros asociados.',
                        color: LivitColors.whiteActive,
                      ),
                      LivitSpaces.xs,
                      LivitText(
                        'Esta acción no se puede deshacer.',
                        fontWeight: FontWeight.bold,
                      ),
                      LivitSpaces.s,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Button.secondary(
                            text: 'Cancelar',
                            isActive: true,
                            onTap: () => Navigator.of(context).pop(),
                          ),
                          Button.redText(
                            text: 'Eliminar',
                            rightIcon: CupertinoIcons.trash,
                            isActive: true,
                            onTap: () {
                              confirmDelete = true;
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
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
    return confirmDelete;
  }

  Future<void> deleteScanner(CloudScanner scanner, BuildContext outerContext) async {
    // Show confirmation dialog
    final shouldDelete = await _showDeleteConfirmationDialog(outerContext, scanner);
    _debugger.debPrint('shouldDelete: $shouldDelete, context.mounted: ${outerContext.mounted}', DebugMessageType.info);

    if (shouldDelete && outerContext.mounted) {
      late final BuildContext afterLoadingContext;
      try {
        showDialog(
            barrierDismissible: false,
            context: outerContext,
            builder: (context) {
              afterLoadingContext = context;
              return Dialog(
                backgroundColor: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LivitBar(
                      shadowType: ShadowType.weak,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LivitText('Eliminando escáner', textType: LivitTextType.smallTitle),
                          LivitSpaces.xs,
                          CupertinoActivityIndicator(
                            color: LivitColors.whiteActive,
                            radius: LivitButtonStyle.bigIconSize / 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            });
        await _firestoreCloudFunctions.deleteScannerAccount(scannerId: scanner.id);

        // Close loading dialog
        if (outerContext.mounted) {
          Navigator.of(afterLoadingContext).pop();

          // Show success dialog
          late final BuildContext afterSuccessContext;
          showDialog(
              context: afterLoadingContext,
              builder: (context) {
                afterSuccessContext = context;
                return Dialog(
                  backgroundColor: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LivitBar(
                        shadowType: ShadowType.weak,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            LivitText('Escáner eliminado', textType: LivitTextType.smallTitle),
                            LivitSpaces.xs,
                            Icon(
                              CupertinoIcons.checkmark_alt_circle,
                              color: LivitColors.whiteActive,
                              size: LivitButtonStyle.bigIconSize,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              });

          // Refresh scanner list
          if (outerContext.mounted) {
            outerContext.read<ScannerBloc>().add(
                  GetScannersByLocationId(locationId: scanner.locationIds?.first ?? ''),
                );
          }
          await Future.delayed(const Duration(seconds: 2));
          if (afterSuccessContext.mounted) {
            Navigator.of(afterSuccessContext).pop();
          }
        }
      } catch (e) {
        if (outerContext.mounted) {
          // Show error dialog
          showDialog(
            context: outerContext,
            builder: (context) => Dialog(
              backgroundColor: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LivitBar(
                    shadowType: ShadowType.weak,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LivitText('Error al eliminar el escáner', textType: LivitTextType.smallTitle),
                        LivitSpaces.xs,
                        Icon(
                          CupertinoIcons.exclamationmark_circle,
                          color: LivitColors.yellowError,
                          size: LivitButtonStyle.bigIconSize,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    }
  }
}
