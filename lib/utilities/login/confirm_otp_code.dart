import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/shadows.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/user_types.dart';
import 'package:livit/services/auth/auth_exceptions.dart';
import 'package:livit/services/auth/bloc/auth_bloc.dart';
import 'package:livit/services/auth/bloc/auth_event.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/bars_containers_fields/title_bar.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:pinput/pinput.dart';
import 'package:livit/services/auth/bloc/auth_state.dart';

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
  String? invalidCode;
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
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateLoggedIn) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.mainViewRoute,
            (_) => false,
          );
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedOut) {
          if (state.exception != null) {
            if (state.exception is InvalidVerificationCodeAuthException) {
              invalidCode = 'Codigo invalido';
            } else if (state.exception is NetworkRequesFailed) {
              invalidCode = 'Error de red';
            } else {
              invalidCode = 'Error desconocido';
            }
          }
          if (state.isLoggingIngWithPhoneAndOtp) {
            _isVerifyingCode = true;
          } else {
            _isVerifyingCode = false;
          }
        } else if (state is AuthStateCodeSent) {
          verificationId = state.verificationId;
        } else if (state is AuthStateCodeSentError) {
          invalidCode = 'Error reenviando el codigo';
        }

        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
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
                                  child: Column(
                                    children: [
                                      const TitleBar(
                                        title: 'Ingresa el código',
                                        isBackEnabled: true,
                                      ),
                                      Padding(
                                        padding: LivitContainerStyle.padding([0, null, null, null]),
                                        child: Column(
                                          children: [
                                            LivitText(
                                              'Hemos enviado un codigo al ${widget.phoneCode} ${widget.phoneNumber}, ingresalo aqui para verificar tu cuenta:',
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
                                            if (invalidCode != null) ...[
                                              LivitSpaces.s,
                                              LivitText(
                                                invalidCode!,
                                                textStyle: TextType.small,
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
                                                  onPressed: () {
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
                                                  onPressed: () {
                                                    setState(() {
                                                      _isVerifyingCode = true;
                                                    });
                                                    context.read<AuthBloc>().add(
                                                          AuthEventLogInWithPhoneAndOtp(
                                                            verificationId: verificationId,
                                                            otpCode: otpController.text,
                                                          ),
                                                        );
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
      },
    );
  }
}
