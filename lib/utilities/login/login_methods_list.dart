import 'package:country_picker_pro/country_picker_pro.dart';
import 'package:flutter/material.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/constants/styles/text_style.dart';
import 'package:livit/services/auth/auth_service.dart';
import 'package:livit/services/cloud/firebase_cloud_storage.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/bars_containers_fields/text_field.dart';
import 'package:livit/utilities/bars_containers_fields/title_bar.dart';
import 'package:livit/utilities/buttons/login_buttons/email_login_bar.dart';
import 'package:livit/utilities/buttons/login_buttons/promoter_login_bar.dart';
import 'package:livit/utilities/buttons/login_buttons/apple_login_bar.dart';
import 'package:livit/utilities/buttons/login_buttons/google_login_bar.dart';
import 'package:livit/utilities/buttons/main_action_button.dart';

class LoginMethodsList extends StatefulWidget {
  final UserType userType;

  const LoginMethodsList({
    super.key,
    required this.userType,
  });

  @override
  State<LoginMethodsList> createState() => _LoginMethodsListState();
}

class _LoginMethodsListState extends State<LoginMethodsList> {
  late final TextEditingController phoneController;
  String selectedCountryCode = '';

  bool isPhoneValid = false;
  bool isCodeSent = false;
  bool _isCodeSending = false;

  bool invalidPhoneError = false;
  bool networkRequestFailedError = false;

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

  @override
  void initState() {
    phoneController = TextEditingController();
    selectedCountryCode = initialCountry.phoneCode;
    super.initState();
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void onPhoneChange(bool isValid) {
    setState(
      () {
        isPhoneValid = isValid;
      },
    );
  }

  void onCodeChange(String countryCode) {
    setState(
      () {
        selectedCountryCode = countryCode;
      },
    );
  }

  void onSendCode(Map<String, dynamic> values) {
    setState(
      () {
        _isCodeSending = false;
      },
    );
    if (values['success']) {
      final Map<String, dynamic> args = {
        'userType': widget.userType,
        'phoneCode': selectedCountryCode,
        'verificationId': values['verificationId'],
        'phoneNumber': phoneController.text,
      };
      Navigator.of(context).pushNamed(
        Routes.confirmOTPCodeRoute,
        arguments: args,
      );
    } else {
      String errorCode = values['errorCode'];
      if (errorCode == 'invalid-phone-number') {
        invalidPhoneError = true;
      } else if (errorCode == 'network-request-failed') {
        networkRequestFailedError = true;
      }
    }
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              GlassContainer(
                child: Padding(
                  padding: LivitContainerStyle.padding([0, null, null, null]),
                  child: Column(
                    children: [
                      TitleBar(
                        title: widget.userType == UserType.customer
                            ? 'Ingresa a Livit'
                            : 'Ingresa como Promocionador',
                        isBackEnabled: widget.userType == UserType.promoter,
                      ),
                      widget.userType == UserType.promoter
                          ? Column(
                              children: [
                                const LivitText(
                                  'En LIVIT podras promocionar tus eventos y negocio, permitiendo que muchos mas clientes te encuentren y tengan una gran experiencia de compra.',
                                ),
                                LivitSpaces.medium16spacer,
                              ],
                            )
                          : const SizedBox(),
                      const AppleLoginBar(),
                      LivitSpaces.medium16spacer,
                      GoogleLoginBar(
                        userType: widget.userType,
                      ),
                      LivitSpaces.medium16spacer,
                      EmailLoginBar(
                        userType: widget.userType,
                      ),
                      LivitSpaces.medium16spacer,
                      const LivitText(
                        'O usa tu número de teléfono',
                      ),
                      LivitSpaces.medium16spacer,
                      LivitTextField(
                        controller: phoneController,
                        hint: 'Número de teléfono',
                        phoneNumberField: true,
                        onChanged: onPhoneChange,
                        initialCountry: initialCountry,
                        onCountryCodeChanged: (value) {
                          setState(
                            () {
                              selectedCountryCode = value;
                            },
                          );
                        },
                        bottomCaptionText: invalidPhoneError
                            ? 'Número de teléfono invalido'
                            : networkRequestFailedError
                                ? 'Error de red'
                                : null,
                      ),
                      LivitSpaces.medium16spacer,
                      MainActionButton(
                        text:
                            _isCodeSending ? 'Enviando codigo...' : 'Continuar',
                        isActive: isPhoneValid,
                        onPressed: () async {
                          setState(
                            () {
                              networkRequestFailedError = false;
                              invalidPhoneError = false;
                              _isCodeSending = true;
                            },
                          );
                          await AuthService.firebase().sendOtpCode(
                            selectedCountryCode,
                            phoneController.text,
                            onSendCode,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              LivitSpaces.mediumPlus24spacer,
              widget.userType == UserType.customer
                  ? GlassContainer(
                      child: Padding(
                        padding: LivitContainerStyle.padding(null),
                        child: Column(
                          children: [
                            const LivitText(
                              'Estas interesado en promocionar tus eventos?',
                            ),
                            LivitSpaces.medium16spacer,
                            const PromoterLoginBar(),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ],
    );
  }
}
