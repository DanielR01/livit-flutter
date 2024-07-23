import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/shadows.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/constants/styles/text_style.dart';
import 'package:livit/enums/credential_types.dart';
import 'package:livit/services/auth/auth_service.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/buttons/arrow_back_button.dart';
import 'package:livit/utilities/buttons/main_action_button.dart';
import 'package:livit/utilities/buttons/secondary_action_button.dart';
import 'package:pinput/pinput.dart';

class ConfirmOTPCode extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final ValueChanged<int> onBack;
  const ConfirmOTPCode({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
    required this.onBack,
  });

  @override
  State<ConfirmOTPCode> createState() => _ConfirmOTPCodeState();
}

class _ConfirmOTPCodeState extends State<ConfirmOTPCode> {
  late final TextEditingController otpController;
  String? otpCode;
  bool isOtpCodeValid = false;

  @override
  void initState() {
    otpController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: GlassContainer(
            opacity: 1,
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: LivitContainerStyle.padding([0, null, null, null]),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: LivitBarStyle.height,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            left: 0,
                            child: ArrowBackButton(
                              onPressed: () {
                                widget.onBack(0);
                                otpController.text = '';
                              },
                            ),
                          ),
                          Text(
                            'Ingresa el código',
                            style: LivitTextStyle(
                              textColor: LivitColors.whiteActive,
                            ).normalTitleTextStyle,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Hemos enviado un codigo al ${widget.phoneNumber}, ingresalo aqui para confirmar tu cuenta:',
                      style: LivitTextStyle(
                        textColor: LivitColors.whiteActive,
                      ).regularTextStyle,
                      textAlign: TextAlign.center,
                    ),
                    LivitSpaces.mediumPlus24spacer,
                    Pinput(
                      autofocus: true,
                      controller: otpController,
                      length: 6,
                      defaultPinTheme: PinTheme(
                        height: LivitBarStyle.height,
                        width: LivitBarStyle.height,
                        decoration: BoxDecoration(
                          color: LivitColors.mainBlack,
                          borderRadius: LivitContainerStyle.radius,
                          //border: Border.all(color: LivitColors.whiteInactive),
                          boxShadow: [
                            LivitShadows.activeWhiteShadow,
                          ],
                        ),
                        textStyle: LivitTextStyle(
                          textColor: LivitColors.whiteActive,
                        ).regularTextStyle,
                      ),
                      onChanged: (value) {
                        setState(
                          () {
                            otpCode = value;
                            if (!RegExp(r'^\d{6}$').hasMatch(otpCode ?? '')) {
                              isOtpCodeValid = false;
                            } else {
                              isOtpCodeValid = true;
                            }
                          },
                        );
                      },
                    ),
                    LivitSpaces.medium16spacer,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const SecondaryActionButton(
                          text: 'No recibí el codigo',
                          isActive: false,
                        ),
                        MainActionButton(
                          text: 'Confirmar',
                          isActive: isOtpCodeValid,
                          onPressed: () async {
                            await AuthService.firebase().logIn(
                              credentialType: CredentialType.phoneAndOtp,
                              credentials: [
                                widget.verificationId,
                                otpController.text,
                              ],
                            );
                            if (AuthService.firebase().currentUser != null) {
                              if (context.mounted) {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    Routes.mainviewRoute, (route) => false);
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
