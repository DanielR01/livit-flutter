import 'dart:async';

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
import 'package:livit/services/auth/credential_types.dart';
import 'package:livit/services/auth/auth_exceptions.dart';
import 'package:livit/services/auth/auth_service.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/buttons/arrow_back_button.dart';
import 'package:livit/utilities/buttons/main_action_button.dart';
import 'package:livit/utilities/buttons/secondary_action_button.dart';
import 'package:pinput/pinput.dart';

class ConfirmOTPCode extends StatefulWidget {
  final String phoneCode;
  final String phoneNumber;
  final String initialVerificationId;
  final ValueChanged<int> onBack;
  const ConfirmOTPCode({
    super.key,
    required this.phoneCode,
    required this.initialVerificationId,
    required this.phoneNumber,
    required this.onBack,
  });

  @override
  State<ConfirmOTPCode> createState() => _ConfirmOTPCodeState();
}

class _ConfirmOTPCodeState extends State<ConfirmOTPCode> {
  late final TextEditingController otpController;

  late String verificationId;

  String? otpCode;
  bool isOtpCodeValid = false;
  bool invalidCode = false;
  late Timer _timer;
  int countdown = 0;
  bool isResendButtonActive = false;

  void onResendedCode(List values) {
    setState(
      () {
        if (values[0]) {
          verificationId = values[1];
        } else {
          //TODO implement generic error handler for resended codes
        }
      },
    );
  }

  void startTimer() {
    setState(
      () {
        isResendButtonActive = false;
        countdown = 35;
      },
    );

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        setState(
          () {
            if (countdown > 1) {
              countdown--;
            } else {
              isResendButtonActive = true;
              _timer.cancel();
            }
          },
        );
      },
    );
  }

  @override
  void initState() {
    otpController = TextEditingController();
    verificationId = widget.initialVerificationId;
    startTimer();
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
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
            //opacity: 1,
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
                                invalidCode = false;
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
                      'Hemos enviado un codigo al +${widget.phoneCode} ${widget.phoneNumber}, ingresalo aqui para confirmar tu cuenta:',
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
                    invalidCode
                        ? Column(
                            children: [
                              LivitSpaces.small8spacer,
                              Text(
                                'Codigo invalido',
                                style: LivitTextStyle(
                                  textColor: LivitColors.whiteActive,
                                ).smallTextStyle,
                              ),
                              LivitSpaces.small8spacer,
                            ],
                          )
                        : LivitSpaces.medium16spacer,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SecondaryActionButton(
                          text: isResendButtonActive
                              ? 'Reenviar codigo'
                              : 'Reenviar codigo... $countdown',
                          isActive: isResendButtonActive,
                          onPressed: () {
                            startTimer();
                            invalidCode = false;
                            AuthService.firebase().sendOtpCode(
                              widget.phoneCode,
                              widget.phoneNumber,
                              (value) {},
                            );
                          },
                        ),
                        MainActionButton(
                          text: 'Confirmar',
                          isActive: isOtpCodeValid,
                          onPressed: () async {
                            try {
                              await AuthService.firebase().logIn(
                                credentialType: CredentialType.phoneAndOtp,
                                credentials: [
                                  verificationId,
                                  otpController.text,
                                ],
                              );
                              if (AuthService.firebase().currentUser != null) {
                                if (context.mounted) {
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      Routes.mainviewRoute, (route) => false);
                                }
                              }
                            } on InvalidVerificationCodeAuthException {
                              otpController.text = '';
                              invalidCode = true;
                              // TODO implement invalidverificationCodeAuthException
                            } on GenericAuthException {
                              //TODO implement genericAuthException
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
