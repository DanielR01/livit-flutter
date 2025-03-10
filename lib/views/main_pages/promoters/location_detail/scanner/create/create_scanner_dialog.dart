import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/services/firestore_storage/bloc/scanner/scanner_bloc.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';
import 'package:livit/utilities/bars_containers_fields/livit_text_field.dart';
import 'package:livit/utilities/buttons/button.dart';

class CreateScannerDialog extends StatefulWidget {
  final String locationId;

  const CreateScannerDialog({
    super.key,
    required this.locationId,
  });

  @override
  State<CreateScannerDialog> createState() => _CreateScannerDialogState();
}

class _CreateScannerDialogState extends State<CreateScannerDialog> {
  late final TextEditingController _scannerNameController;
  bool _isScannerNameValid = false;
  String _scannerName = '';
  late final ScannerBloc _scannerBloc;

  @override
  void initState() {
    super.initState();
    _scannerNameController = TextEditingController();
    _scannerBloc = context.read<ScannerBloc>();
    _scannerNameController.addListener(() {
      final text = _scannerNameController.text;
      setState(() {
        _scannerName = text;
        _isScannerNameValid = RegExp(r'^[a-zA-Z0-9]{3,20}$').hasMatch(text);
      });
    });
  }

  @override
  void dispose() {
    _scannerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          Column(
            children: [
              Container(
                decoration: LivitContainerStyle.decorationWithInactiveShadow,
                child: Padding(
                  padding: LivitContainerStyle.padding(),
                  child: LivitText(
                    'Recuerda que podrás usar esta cuenta para validar los tickets o productos de los clientes de esta ubicación. Solo tú puedes crear y eliminar escáneres en cualquier momento.',
                  ),
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
                        'Aunque no es obligatorio, recomendamos darle un nombre o apodo al escáner para que puedas identificarlo fácilmente. Este puede contener entre 3 y 20 letras o números.',
                        color: LivitColors.whiteInactive,
                      ),
                      LivitSpaces.s,
                      LivitTextField(
                        controller: _scannerNameController,
                        hint: 'Nombre o apodo',
                        regExp: RegExp(r'^[a-zA-Z0-9]{3,20}$'),
                        onChanged: (value) {
                          setState(() {
                            _isScannerNameValid = value;
                          });
                        },
                        onClear: () {
                          setState(() {});
                        },
                      ),
                      LivitSpaces.s,
                      BlocBuilder<ScannerBloc, ScannerState>(
                        builder: (context, state) {
                          final bool isLoading = state is ScannerLoading;
                          return Button.main(
                            text: isLoading ? 'Creando scanner' : 'Crear escáner',
                            isActive: _scannerNameController.text.isEmpty || _isScannerNameValid,
                            isLoading: isLoading,
                            onTap: () {
                              _scannerBloc.add(
                                CreateScanner(
                                  locationId: widget.locationId,
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
        ],
      ),
    );
  }
}
