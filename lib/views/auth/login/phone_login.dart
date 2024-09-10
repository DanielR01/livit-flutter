import 'package:country_picker_pro/country_picker_pro.dart';
import 'package:flutter/material.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/constants/user_types.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/bars_containers_fields/text_field.dart';
import 'package:livit/utilities/bars_containers_fields/title_bar.dart';
import 'package:livit/utilities/buttons/button.dart';

class PhoneLogin extends StatefulWidget {
  final UserType userType;
  const PhoneLogin({
    super.key,
    required this.userType,
  });

  @override
  State<PhoneLogin> createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<PhoneLogin> {
  String? phoneError;
  late TextEditingController _phoneController;
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
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
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
                              TitleBar(
                                title: 'Continuar con número de teléfono',
                                isBackEnabled: true,
                              ),
                              const LivitText('Ingresa tu número de teléfono, te llegará un código de verificación.'),
                              LivitSpaces.m,
                              LivitTextField(
                                controller: _phoneController,
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
                                bottomCaptionText: phoneError,
                              ),
                              LivitSpaces.m,
                              Button.main(
                                text: 'Enviar código',
                                isActive: isPhoneValid,
                                onPressed: () {},
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
    );
  }
}
