import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/shadows.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/models/location/location.dart';
import 'package:livit/models/user/cloud_user.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_state.dart';
import 'package:livit/services/firestore_storage/bloc/scanner/scanner_bloc.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/bars_containers_fields/livit_text_field.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/views/main_pages/promoters/location_detail/scanner/location_scanner_preview_field.dart';

class LocationScannersPreview extends StatefulWidget {
  const LocationScannersPreview({super.key});

  @override
  State<LocationScannersPreview> createState() => _LocationScannersPreviewState();
}

class _LocationScannersPreviewState extends State<LocationScannersPreview> {
  LivitLocation? _location;
  late final LocationBloc _locationBloc;
  late final ScannerBloc _scannerBloc;

  List<CloudScanner> _scanners = [];

  late final TextEditingController _scannerNameController;
  bool _isScannerNameValid = false;
  String _scannerName = '';

  Future<void> _showScannerCreatedDialog(CloudScanner scanner) async {
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
                      CupertinoIcons.checkmark_circle,
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
                            CupertinoIcons.person,
                            color: LivitColors.whiteActive,
                            size: LivitButtonStyle.iconSize,
                          ),
                          LivitSpaces.xs,
                          LivitText('Nombre: ${scanner.name}'),
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
                          LivitText('Email: ${scanner.email}'),
                        ],
                      ),
                      LivitSpaces.m,
                      LivitText(
                        'Se ha enviado un correo con las credenciales al promotor.',
                        color: LivitColors.whiteInactive,
                      ),
                    ],
                  ),
                ),
              ),
              LivitSpaces.s,
              Button.main(
                text: 'Aceptar',
                isActive: true,
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> onTapCreateScanner() async {
    await showDialog(
      barrierColor: LivitColors.mainBlackDialog,
      context: context,
      builder: (BuildContext context) {
        return BlocListener<ScannerBloc, ScannerState>(
          listener: (context, state) {
            if (state is ScannerSuccess && state.createdScanner != null) {
              Navigator.of(context).pop(); // Close the create scanner dialog
              _showScannerCreatedDialog(state.createdScanner!);
            }
          },
          child: StatefulBuilder(
            builder: (context, dialogSetState) {
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
                          LivitText('Crear escáner', textType: LivitTextType.smallTitle),
                          LivitSpaces.xs,
                          Icon(
                            CupertinoIcons.qrcode_viewfinder,
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
                        child: LivitText(
                            'Recuerda que podras usar esta cuenta para validar los tickets o productos de los clientes de esta ubicación. Solo tu puedes crear y eliminar escáneres en cualquier momento.'),
                      ),
                    ),
                    LivitSpaces.xs,
                    Container(
                      decoration: LivitContainerStyle.decorationWithInactiveShadow,
                      child: Padding(
                        padding: LivitContainerStyle.padding(),
                        child: Column(
                          children: [
                            LivitText(
                              'Aunque no es obligatorio, recomendamos darle un nombre o apodo al escáner para que puedas identificarlo fácilmente. Este puede contener entre 3 y 20 letras en minusculas o numeros.',
                              color: LivitColors.whiteInactive,
                            ),
                            LivitSpaces.s,
                            LivitTextField(
                              controller: _scannerNameController,
                              hint: 'Nombre o apodo',
                              regExp: RegExp(r'^[a-z0-9]{3,20}$'),
                              onChanged: (value) {
                                dialogSetState(() {
                                  _isScannerNameValid = value;
                                });
                              },
                              onClear: () {
                                dialogSetState(() {});
                              },
                            ),
                            LivitSpaces.s,
                            BlocBuilder<ScannerBloc, ScannerState>(
                              builder: (context, state) {
                                final bool isLoading = _scannerBloc.state is ScannerLoading;
                                return Button.main(
                                  text: isLoading ? 'Creando scanner' : 'Crear escáner',
                                  isActive: _scannerNameController.text.isEmpty || _isScannerNameValid,
                                  isLoading: isLoading,
                                  onTap: () {
                                    _scannerBloc.add(
                                      CreateScanner(
                                        locationId: _location!.id,
                                        name: _scannerName,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _scannerNameController = TextEditingController();
    _scannerNameController.addListener(() {
      final text = _scannerNameController.text;
      setState(() {
        _scannerName = text;
        _isScannerNameValid = RegExp(r'^[a-z0-9]{3,20}$').hasMatch(text);
      });
    });
    _locationBloc = context.read<LocationBloc>();
    _scannerBloc = context.read<ScannerBloc>();
    _location = _locationBloc.currentLocation;
    if (_location != null) {
      _scannerBloc.add(GetScannersByLocationId(locationId: _location!.id));
    }
  }

  @override
  void dispose() {
    _scannerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationBloc, LocationState>(
      listener: (context, state) {
        if (_locationBloc.currentLocation != _location) {
          _location = _locationBloc.currentLocation;
          if (_location != null) {
            _scannerBloc.add(GetScannersByLocationId(locationId: _location!.id));
          }
        }
      },
      child: BlocBuilder<ScannerBloc, ScannerState>(
        builder: (context, state) {
          debugPrint('[LocationScannersPreview] scannerName: $_scannerName, isScannerNameValid: $_isScannerNameValid');
          late final Widget bar;
          late final Widget content;

          if (_scannerBloc.state is ScannerSuccess) {
            _scanners = (_scannerBloc.state as ScannerSuccess).scanners;
          }

          if (_scanners.isEmpty) {
            bar = LivitBar(
              shadowType: ShadowType.weak,
              child: LivitText(
                'Escáneres',
                textType: LivitTextType.smallTitle,
              ),
            );
          } else {
            bar = LivitBar.expandable(
              buttons: [
                Button.secondary(
                  boxShadow: [LivitShadows.inactiveWhiteShadow],
                  text: 'Crear nuevo escaner',
                  rightIcon: CupertinoIcons.qrcode_viewfinder,
                  isActive: true,
                  onTap: onTapCreateScanner,
                )
              ],
              titleText: 'Escáneres',
            );
          }

          if (_scannerBloc.state is ScannerLoading || _scannerBloc.state is ScannerInitial) {
            content = Center(
              child: CupertinoActivityIndicator(
                color: LivitColors.whiteActive,
                radius: LivitButtonStyle.iconSize / 2,
              ),
            );
          } else if (_scannerBloc.state is ScannerSuccess) {
            if (_scanners.isEmpty) {
              content = Center(
                child: Button.main(
                  text: 'Crear escáner',
                  rightIcon: CupertinoIcons.qrcode_viewfinder,
                  isActive: true,
                  onTap: onTapCreateScanner,
                ),
              );
            } else {
              content = ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: _scanners.length,
                  separatorBuilder: (context, index) => LivitSpaces.s,
                  itemBuilder: (context, index) => LocationScannerPreviewField(scanner: _scanners[index]),
                ),
              );
            }
          } else if (_scannerBloc.state is ScannerError) {
            content = Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LivitText('Error al cargar escáneres'),
                  LivitSpaces.xs,
                  Icon(
                    CupertinoIcons.exclamationmark_circle,
                    color: LivitColors.yellowError,
                  ),
                ],
              ),
            );
          }
          return GlassContainer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                bar,
                Padding(
                  padding: LivitContainerStyle.padding(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LivitText(
                        'Los escáneres son cuentas que podran leer y validar los codigos QR de los clientes de esta ubicación.',
                      ),
                      LivitSpaces.s,
                      content,
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
