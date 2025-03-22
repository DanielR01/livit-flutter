import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/shadows.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/models/event/event.dart';
import 'package:livit/models/location/location.dart';
import 'package:livit/models/user/cloud_user.dart';
import 'package:livit/services/firestore_storage/firestore_storage/firestore_storage.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/views/main_pages/promoters/location_detail/scanner/delete/delete_scanner.dart';

class LocationScannerPreviewField extends StatelessWidget {
  final CloudScanner scanner;
  final FirestoreStorageService _firestoreStorageService;
  LocationScannerPreviewField({super.key, required this.scanner}) : _firestoreStorageService = FirestoreStorageService();

  String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$day/$month/$year a las $hour:$minute $period';
  }

  Future<void> onTap(BuildContext context) async {
    final BuildContext outerContext = context;

    // Pre-fetch location and event data to avoid multiple API calls
    final locationsData = scanner.locationIds?.isNotEmpty == true
        ? await _firestoreStorageService.locationService.getLocationsByIds(scanner.locationIds!.whereType<String>().toList())
        : <LivitLocation>[];

    final eventsData = scanner.eventIds?.isNotEmpty == true
        ? await _firestoreStorageService.eventService.getEventsByIds(scanner.eventIds!.whereType<String>().toList())
        : <LivitEvent>[];

    if (!context.mounted) return;

    bool isEmailCopied = false;
    String displayText = scanner.email;

    await showDialog(
      context: context,
      barrierColor: LivitColors.mainBlackDialog,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LivitBar.expandable(
                shadowType: ShadowType.normal,
                titleText: scanner.name,
                icon: CupertinoIcons.qrcode_viewfinder,
                buttons: [
                  Button.secondary(
                    boxShadow: [LivitShadows.inactiveWhiteShadow],
                    isIconBig: false,
                    text: 'Configuración',
                    rightIcon: CupertinoIcons.wrench,
                    isActive: true,
                    onTap: () {},
                  ),
                  Button.secondary(
                    boxShadow: [LivitShadows.inactiveWhiteShadow],
                    isIconBig: false,
                    text: 'Registros',
                    rightIcon: CupertinoIcons.list_bullet,
                    isActive: true,
                    onTap: () {},
                  ),
                ],
              ),
              LivitSpaces.m,
              LivitBar(
                shadowType: ShadowType.weak,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
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
                              isEmailCopied ? CupertinoIcons.checkmark_alt : CupertinoIcons.at,
                              color: LivitColors.whiteActive,
                              size: LivitButtonStyle.iconSize,
                            ),
                            LivitSpaces.xs,
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: scanner.email));
                                  setState(() {
                                    isEmailCopied = true;
                                    displayText = "Email copiado";
                                  });
                                  Future.delayed(const Duration(seconds: 2), () {
                                    if (context.mounted) {
                                      setState(() {
                                        isEmailCopied = false;
                                        displayText = scanner.email;
                                      });
                                    }
                                  });
                                },
                                child: LivitText(
                                  displayText,
                                  textAlign: TextAlign.start,
                                  color: isEmailCopied ? LivitColors.whiteActive : LivitColors.whiteActive,
                                  fontWeight: isEmailCopied ? FontWeight.bold : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    LivitSpaces.xs,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          CupertinoIcons.clock,
                          color: LivitColors.whiteActive,
                          size: LivitButtonStyle.iconSize,
                        ),
                        LivitSpaces.xs,
                        Flexible(
                          child: LivitText(
                            'Creado el ${_formatDateTime(scanner.createdAt.toDate())}',
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),

                    // Use the pre-fetched data instead of calling FutureBuilder
                    if (locationsData.isNotEmpty) ...[
                      LivitSpaces.xs,
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
                            LivitText(locationsData[index].name, textAlign: TextAlign.start),
                          ],
                        ),
                        separatorBuilder: (context, index) => LivitSpaces.s,
                        itemCount: locationsData.length,
                      ),
                    ],

                    if (eventsData.isNotEmpty) ...[
                      LivitSpaces.xs,
                      LivitText(
                        'Esta cuenta puede escanear en los siguientes eventos:',
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.start,
                      ),
                      LivitSpaces.xs,
                      ListView.separated(
                        shrinkWrap: true,
                        itemBuilder: (context, index) => Row(
                          children: [
                            Icon(
                              CupertinoIcons.calendar,
                              color: LivitColors.whiteActive,
                              size: LivitButtonStyle.iconSize,
                            ),
                            LivitSpaces.xs,
                            LivitText(eventsData[index].name, textAlign: TextAlign.start),
                          ],
                        ),
                        separatorBuilder: (context, index) => LivitSpaces.s,
                        itemCount: eventsData.length,
                      ),
                    ],
                    LivitSpaces.s,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Button.redText(
                          text: 'Eliminar',
                          rightIcon: CupertinoIcons.trash,
                          isIconBig: false,
                          isActive: true,
                          onTap: () async {
                            // Close the scanner details dialog first
                            Navigator.of(context).pop();

                            DeleteScanner().deleteScanner(scanner, outerContext);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LivitBar.touchable(
      shadowType: ShadowType.weak,
      child: Padding(
        padding: LivitContainerStyle.padding(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LivitText(scanner.name, textType: LivitTextType.smallTitle),
            LivitSpaces.xs,
            LivitText(scanner.email),
          ],
        ),
      ),
      onTap: () => onTap(context),
    );
  }
}
