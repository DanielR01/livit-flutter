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
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/livit_scrollbar.dart';
import 'package:livit/views/main_pages/promoters/location_detail/scanner/created/show_scanner_created_dialog.dart';
import 'package:livit/views/main_pages/promoters/location_detail/scanner/location_scanner_preview_field.dart';
import 'package:livit/views/main_pages/promoters/location_detail/scanner/create/create_scanner_dialog.dart';

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

  Future<void> onTapCreateScanner() async {
    await showDialog(
      barrierColor: LivitColors.mainBlackDialog,
      context: context,
      builder: (BuildContext context) {
        return BlocListener<ScannerBloc, ScannerState>(
          listener: (context, state) {
            if (state is ScannerSuccess && state.createdScanner != null) {
              Navigator.of(context).pop(); // Close the create scanner dialog
              ShowScannerCreatedDialog().showScannerCreatedDialog(state.createdScanner!, context);
            }
          },
          child: CreateScannerDialog(
            locationId: _location!.id,
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _locationBloc = context.read<LocationBloc>();
    _scannerBloc = context.read<ScannerBloc>();
    _location = _locationBloc.currentLocation;
    if (_location != null) {
      _scannerBloc.add(GetScannersByLocationId(locationId: _location!.id));
    }
  }

  @override
  void dispose() {
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
              content = Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Button.main(
                    text: 'Crear escáner',
                    rightIcon: CupertinoIcons.qrcode_viewfinder,
                    isActive: true,
                    onTap: onTapCreateScanner,
                  ),
                  LivitSpaces.s,
                ],
              );
            } else {
              content = ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: LivitScrollbar(
                  child: ListView.separated(
                    padding: LivitContainerStyle.padding(padding: [LivitSpaces.sDouble, null, null, null]),
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _scanners.length,
                    separatorBuilder: (context, index) => LivitSpaces.s,
                    itemBuilder: (context, index) => LocationScannerPreviewField(scanner: _scanners[index]),
                  ),
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
                  LivitSpaces.s,
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
                  padding: LivitContainerStyle.padding(padding: [null, null, 0, null]),
                  child: LivitText(
                    'Los escáneres son cuentas que podran leer y validar los codigos QR de los clientes de esta ubicación.',
                  ),
                ),
                LivitSpaces.xs,
                content,
              ],
            ),
          );
        },
      ),
    );
  }
}
