import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/models/user/cloud_user.dart';
import 'package:livit/services/firestore_storage/firestore_storage/firestore_storage.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';
import 'package:livit/utilities/buttons/button.dart';

class ShowScannerCreatedDialog {
  final FirestoreStorageService _firestoreStorageService = FirestoreStorageService();

  Widget _showScannerLocations(CloudScanner scanner) {
    if (scanner.locationIds == null || scanner.locationIds!.isEmpty) {
      return const SizedBox.shrink();
    }
    return FutureBuilder(
      future: _firestoreStorageService.locationService.getLocationsByIds(scanner.locationIds!.whereType<String>().toList()),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.connectionState == ConnectionState.done && snapshot.data!.isNotEmpty) {
          debugPrint('📥 [LocationScannersPreview] Showing scanner locations: ${snapshot.data!}');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LivitText(
                'Esta cuenta puede escanear en las siguientes ubicaciones:',
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.start,
              ),
              LivitSpaces.xs,
              ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) => Row(
                  children: [
                    Icon(
                      CupertinoIcons.location,
                      color: LivitColors.whiteActive,
                      size: LivitButtonStyle.iconSize,
                    ),
                    LivitSpaces.xs,
                    LivitText(snapshot.data![index].name, textAlign: TextAlign.start),
                  ],
                ),
                separatorBuilder: (context, index) => LivitSpaces.s,
                itemCount: snapshot.data!.length,
              ),
              LivitSpaces.s,
            ],
          );
        } else {
          return CupertinoActivityIndicator(
            color: LivitColors.whiteActive,
            radius: LivitButtonStyle.iconSize / 2,
          );
        }
      },
    );
  }

  Widget _showScannerEvents(CloudScanner scanner) {
    if (scanner.eventIds == null || scanner.eventIds!.isEmpty) {
      return const SizedBox.shrink();
    }
    return FutureBuilder(
      future: _firestoreStorageService.eventService.getEventsByIds(scanner.eventIds!.whereType<String>().toList()),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.connectionState == ConnectionState.done && snapshot.data!.isNotEmpty) {
          return Column(
            children: [
              LivitText('Esta cuenta puede escanear en los siguientes eventos:', fontWeight: FontWeight.bold),
              LivitSpaces.xs,
              ListView.separated(
                itemBuilder: (context, index) => Row(
                  children: [
                    Icon(
                      CupertinoIcons.calendar,
                      color: LivitColors.whiteActive,
                      size: LivitButtonStyle.iconSize,
                    ),
                    LivitSpaces.xs,
                    LivitText(snapshot.data![index].name, textAlign: TextAlign.start),
                  ],
                ),
                separatorBuilder: (context, index) => LivitSpaces.s,
                itemCount: snapshot.data!.length,
                shrinkWrap: true,
              ),
              LivitSpaces.s,
            ],
          );
        } else {
          return CupertinoActivityIndicator(
            color: LivitColors.whiteActive,
            radius: LivitButtonStyle.iconSize / 2,
          );
        }
      },
    );
  }

  Future<void> showScannerCreatedDialog(CloudScanner scanner, BuildContext context) async {
    await showDialog(
      barrierColor: LivitColors.mainBlackDialog,
      context: context,
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
                    LivitText('Escáner creado', textType: LivitTextType.smallTitle),
                    LivitSpaces.xs,
                    Icon(
                      CupertinoIcons.checkmark_alt_circle,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LivitText(
                        'Información del escáner:',
                        textType: LivitTextType.smallTitle,
                      ),
                      LivitSpaces.s,
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.qrcode_viewfinder,
                            color: LivitColors.whiteActive,
                            size: LivitButtonStyle.iconSize,
                          ),
                          LivitSpaces.xs,
                          Flexible(child: LivitText(scanner.name)),
                        ],
                      ),
                      LivitSpaces.xs,
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.mail,
                            color: LivitColors.whiteActive,
                            size: LivitButtonStyle.iconSize,
                          ),
                          LivitSpaces.xs,
                          Flexible(child: LivitText(scanner.email)),
                        ],
                      ),
                      LivitSpaces.s,
                      if (scanner.credentialsSent) ...[
                        _showScannerLocations(scanner),
                        _showScannerEvents(scanner),
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.exclamationmark_circle,
                              color: LivitColors.whiteInactive,
                              size: LivitButtonStyle.iconSize,
                            ),
                            LivitSpaces.xs,
                            Flexible(
                              child: LivitText(
                                'Se ha enviado un correo con las credenciales al promotor.',
                                color: LivitColors.whiteInactive,
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ],
                        ),
                        LivitSpaces.s,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Button.main(
                              text: 'Terminar',
                              isActive: true,
                              onTap: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ] else ...[
                        _showScannerLocations(scanner),
                        _showScannerEvents(scanner),
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.exclamationmark_circle,
                              color: LivitColors.whiteInactive,
                              size: LivitButtonStyle.iconSize,
                            ),
                            LivitSpaces.xs,
                            Flexible(
                              child: LivitText(
                                'El escáner se ha creado correctamente, pero no se ha podido enviar un correo con las credenciales al promotor.',
                                color: LivitColors.whiteInactive,
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ],
                        ),
                        LivitSpaces.s,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Button.main(
                              text: 'Reintentar',
                              isActive: true,
                              onTap: () => {},
                            ),
                          ],
                        ),
                      ],
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
}
