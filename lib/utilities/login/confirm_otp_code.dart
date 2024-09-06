import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/shadows.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/services/auth/bloc/auth_bloc.dart';
import 'package:livit/services/auth/bloc/auth_event.dart';
import 'package:livit/services/auth/auth_exceptions.dart';
import 'package:livit/services/cloud/firebase_cloud_storage.dart';
import 'package:livit/utilities/background/main_background.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/bars_containers_fields/title_bar.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:pinput/pinput.dart';

class ConfirmOTPCodeView extends StatefulWidget {
  final UserType userType;
  final String phoneCode;
  final String phoneNumber;
  final String initialVerificationId;
  const ConfirmOTPCodeView({
    super.key,
    required this.userType,
    required this.phoneCode,
    required this.initialVerificationId,
    required this.phoneNumber,
  });

  @override
  State<ConfirmOTPCodeView> createState() => _ConfirmOTPCodeViewState();
}

class _ConfirmOTPCodeViewState extends State<ConfirmOTPCodeView> {
  late final TextEditingController otpController;

  late String verificationId;

  String? otpCode;
  bool isOtpCodeValid = false;
  bool invalidCode = false;
  late Timer _timer;
  int countdown = 0;
  bool isResendButtonActive = false;
  bool _isVerifyingCode = false;

  void onResendedCode(Map<String, dynamic> values) {
    setState(
      () {
        if (values['success']) {
          verificationId = values['verificationId'];
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
        countdown = 45;
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const MainBackground(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: LivitContainerStyle.paddingFromScreen,
                          child: GlassContainer(
                            child: SizedBox(
                              width: double.infinity,
                              child: Padding(
                                padding: LivitContainerStyle.padding([0, null, null, null]),
                                child: Column(
                                  children: [
                                    const TitleBar(
                                      title: 'Ingresa el código',
                                      isBackEnabled: true,
                                    ),
                                    LivitText(
                                      'Hemos enviado un codigo al +${widget.phoneCode} ${widget.phoneNumber}, ingresalo aqui para verificar tu cuenta:',
                                    ),
                                    LivitSpaces.m,
                                    Pinput(
                                      onTapOutside: (event) {
                                        FocusManager.instance.primaryFocus?.unfocus();
                                      },
                                      autofocus: true,
                                      controller: otpController,
                                      length: 6,
                                      defaultPinTheme: PinTheme(
                                        height: LivitBarStyle.height,
                                        width: LivitBarStyle.height,
                                        decoration: BoxDecoration(
                                          color: LivitColors.mainBlack,
                                          borderRadius: LivitContainerStyle.radius,
                                          boxShadow: [
                                            LivitShadows.activeWhiteShadow,
                                          ],
                                        ),
                                        textStyle: LivitTextStyle.regularWhiteActiveText,
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          otpCode = value;
                                          isOtpCodeValid = RegExp(r'^\d{6}$').hasMatch(otpCode ?? '');
                                        });
                                      },
                                    ),
                                    if (invalidCode) ...[
                                      LivitSpaces.s,
                                      const LivitText(
                                        'Codigo invalido',
                                        textType: TextType.small,
                                      ),
                                    ],
                                    LivitSpaces.m,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Button.secondary(
                                          blueStyle: false,
                                          text: isResendButtonActive ? 'Reenviar codigo' : 'Reenviar codigo... $countdown',
                                          isActive: isResendButtonActive,
                                          onPressed: () async {
                                            invalidCode = false;
                                            context.read<AuthBloc>().add(
                                                  AuthEventSendOtpCode(
                                                    phoneCode: widget.phoneCode,
                                                    phoneNumber: widget.phoneNumber,
                                                  ),
                                                );
                                            startTimer();
                                          },
                                        ),
                                        Button.main(
                                          text: _isVerifyingCode ? 'Verificando...' : 'Verificar',
                                          isActive: isOtpCodeValid,
                                          onPressed: () async {
                                            setState(() {
                                              _isVerifyingCode = true;
                                            });
                                            try {
                                              context.read<AuthBloc>().add(AuthEventLogInWithPhoneAndOtp(
                                                    verificationId: verificationId,
                                                    otpCode: otpController.text,
                                                  ));
                                            } on InvalidVerificationCodeAuthException {
                                              otpController.text = '';
                                              invalidCode = true;
                                              // TODO implement invalidverificationCodeAuthException
                                            } on GenericAuthException {
                                              //TODO implement genericAuthException
                                            }
                                            setState(() {
                                              _isVerifyingCode = false;
                                            });
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
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
