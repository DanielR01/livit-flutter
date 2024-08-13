import 'package:country_picker_pro/country_picker_pro.dart';
import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/constants/styles/text_style.dart';
import 'package:livit/services/auth/auth_service.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/bars_containers_fields/text_field.dart';
import 'package:livit/utilities/buttons/login_buttons/promoter_login_bar.dart';
import 'package:livit/utilities/buttons/action_button.dart';
import 'package:livit/utilities/buttons/login_buttons/apple_login_bar.dart';
import 'package:livit/utilities/buttons/login_buttons/google_login_bar.dart';

class LoginMethodsList extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final ValueChanged<List<String>> phoneLoginCallback;
  final VoidCallback promoterAuthCallback;

  const LoginMethodsList({
    super.key,
    required this.scaffoldKey,
    required this.phoneLoginCallback,
    required this.promoterAuthCallback,
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

  void onSendCode(List values) {
    setState(
      () {
        _isCodeSending = false;
        if (values[0]) {
          widget.phoneLoginCallback(
            [
              selectedCountryCode,
              phoneController.text,
              values[1],
            ],
          );
        } else {
          if (values[1] == 'invalid-phone-number') {
            invalidPhoneError = true;
          } else if (values[1] == 'network-request-failed') {
            networkRequestFailedError = true;
          }
        }
      },
    );
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
                  padding: LivitContainerStyle.padding(null),
                  child: Column(
                    children: [
                      Text(
                        'Iniciar sesión',
                        style: LivitTextStyle(
                          textColor: LivitColors.whiteActive,
                        ).normalTitleTextStyle,
                      ),
                      LivitSpaces.medium16spacer,
                      const GoogleLoginBar(),
                      LivitSpaces.medium16spacer,
                      const AppleLoginBar(),
                      LivitSpaces.medium16spacer,
                      Text(
                        'O usa tu número de teléfono',
                        style: LivitTextStyle(
                          textColor: LivitColors.whiteActive,
                        ).regularTextStyle,
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
                        bottomCaptionStyle: LivitTextStyle(
                          textColor: LivitColors.whiteActive,
                          textWeight: FontWeight.bold,
                        ).smallTextStyle,
                      ),
                      LivitSpaces.medium16spacer,
                      ActionButton(
                        mainAction: true,
                        text:
                            _isCodeSending ? 'Enviando codigo...' : 'Continuar',
                        isActive: isPhoneValid,
                        onPressed: () async {
                          setState(() {
                            networkRequestFailedError = false;
                            invalidPhoneError = false;
                            _isCodeSending = true;
                          });
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
              GlassContainer(
                  child: Padding(
                padding: LivitContainerStyle.padding(null),
                child: Column(
                  children: [
                    Text(
                      'Estas interesado en promocionar tus eventos?',
                      style: LivitTextStyle(
                        textColor: LivitColors.whiteActive,
                      ).regularTextStyle,
                    ),
                    LivitSpaces.medium16spacer,
                    PromoterLoginBar(
                      parentContext: context,
                      scaffoldKey: widget.scaffoldKey,
                      onPressed: () {
                        widget.promoterAuthCallback();
                      },
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }
}
