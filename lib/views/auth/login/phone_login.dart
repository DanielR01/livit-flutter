import 'package:country_picker_pro/country_picker_pro.dart';
import 'package:flutter/material.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/constants/user_types.dart';
import 'package:livit/services/auth/auth_exceptions.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/bars_containers_fields/text_field.dart';
import 'package:livit/utilities/bars_containers_fields/title_bar.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/services/auth/bloc/auth_bloc.dart';
import 'package:livit/services/auth/bloc/auth_event.dart';
import 'package:livit/services/auth/bloc/auth_state.dart';

class PhoneLoginView extends StatefulWidget {
  final UserType userType;
  const PhoneLoginView({
    super.key,
    required this.userType,
  });

  @override
  State<PhoneLoginView> createState() => _PhoneLoginViewState();
}

class _PhoneLoginViewState extends State<PhoneLoginView> {
  String? phoneError;
  late TextEditingController _phoneController;
  bool _isSendingCode = false;
  bool isPhoneValid = false;
  String selectedCountryCode = '+57';

  @override
  void initState() {
    _phoneController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void onPhoneChange(bool isValid) {
    setState(() {
      isPhoneValid = isValid;
    });
  }

  void onPhoneCleared() {
    setState(() {
      isPhoneValid = false;
    });
  }

  void onCodeChange(String countryCode) {
    setState(
      () {
        selectedCountryCode = countryCode;
      },
    );
  }

  Country initialCountry = Country(
    phoneCode: '57',
    countryCode: 'CO',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'COLOMBIA',
    example: 'COLOMBIA',
    displayName: 'COLOMBIA',
    displayNameNoCountryCode: 'CO',
    e164Key: '',
    capital: 'Bogota',
    language: 'Spanish',
  );

  bool _isFirstTime = true;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateCodeSent && _isFirstTime) {
          _isFirstTime = false;
          Navigator.of(context).pushNamed(
            Routes.confirmOTPCodeRoute,
            arguments: {
              'userType': widget.userType,
              'phoneCode': selectedCountryCode,
              'initialVerificationId': state.verificationId,
              'phoneNumber': _phoneController.text,
            },
          );
        }
      },
      builder: (context, state) {
        if (state is AuthStateSendingCode) {
          _isSendingCode = true;
        } else if (state is AuthStateCodeSentError) {
          _isSendingCode = false;
          if (state.exception is InvalidPhoneNumberAuthException) {
            phoneError = 'El número de teléfono no es válido.';
          } else {
            phoneError = '${state.exception.toString()}, intenta de nuevo más tarde.';
          }
        }
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
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
                                    title: 'Continuar con número de teléfono',
                                    isBackEnabled: true,
                                  ),
                                  Padding(
                                    padding: LivitContainerStyle.padding([0, null, null, null]),
                                    child: Column(
                                      children: [
                                        const LivitText('Ingresa tu número de teléfono, te llegará un código de verificación.'),
                                        LivitSpaces.m,
                                        LivitTextField(
                                          controller: _phoneController,
                                          hint: 'Número de teléfono',
                                          phoneNumberField: true,
                                          onChanged: onPhoneChange,
                                          onClear: onPhoneCleared,
                                          initialCountry: initialCountry,
                                          onCountryCodeChanged: (value) {
                                            setState(
                                              () {
                                                selectedCountryCode = value;
                                              },
                                            );
                                          },
                                          bottomCaptionText: phoneError,
                                        ),
                                        LivitSpaces.m,
                                        Button.main(
                                          text: _isSendingCode ? 'Enviando código...' : 'Enviar código',
                                          isActive: isPhoneValid,
                                          isLoading: _isSendingCode,
                                          onPressed: () {
                                            context.read<AuthBloc>().add(
                                                  AuthEventSendOtpCode(
                                                    isResending: false,
                                                    phoneCode: selectedCountryCode,
                                                    phoneNumber: _phoneController.text,
                                                  ),
                                                );
                                          },
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
        );
      },
    );
  }
}
