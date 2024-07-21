import 'package:country_picker_pro/country_picker_pro.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/utilities/buttons/main_action_button.dart';
import 'package:livit/utilities/error_dialogs/show_error_dialog_2t_1b.dart';

class AuthNumberView extends StatefulWidget {
  final bool isLogin;
  const AuthNumberView({
    super.key,
    required this.isLogin,
  });

  @override
  State<AuthNumberView> createState() => AuthNumberViewState();
}

class AuthNumberViewState extends State<AuthNumberView> {
  final GlobalKey scaffoldKey = GlobalKey<ScaffoldState>();
  late final TextEditingController _numberFieldController;
  bool valid = false;

  Country selectedCountry = Country(
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
    _numberFieldController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _numberFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
            child: Column(
              children: [
                Text(
                  widget.isLogin ? 'Login' : 'Register',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: LivitColors.whiteActive,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Enter your phone number. We will send you a verification code:',
                  style: TextStyle(
                    fontSize: 14,
                    color: LivitColors.whiteActive,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 40,
                ),
                TextFormField(
                  autovalidateMode: AutovalidateMode.always,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      if (!RegExp(r'^\d{4,15}$')
                          .hasMatch(_numberFieldController.text)) {
                        valid = false;
                      } else {
                        valid = true;
                      }
                    });
                  },
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: LivitColors.whiteActive),
                  controller: _numberFieldController,
                  decoration: InputDecoration(
                      hintText: 'Enter phone number',
                      hintStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: LivitColors.inactiveGray,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: LivitColors.inactiveGray,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: LivitColors.whiteActive),
                      ),
                      prefixIcon: Container(
                        padding: const EdgeInsets.all(16),
                        child: InkWell(
                          onTap: () {
                            showCountryListView(
                              searchBarOuterBackgroundColor:
                                  LivitColors.mainBlack,
                              searchBarBackgroundColor: LivitColors.mainBlack,
                              appBarBackgroundColour: LivitColors.mainBlack,
                              backgroundColour: LivitColors.mainBlack,
                              countryTextColour: LivitColors.whiteActive,
                              searchBarBorderColor: LivitColors.inactiveGray,
                              searchBarHintColor: LivitColors.inactiveGray,
                              searchBarTextColor: LivitColors.whiteActive,
                              context: context,
                              onSelect: (value) {
                                print(value.example);
                                setState(
                                  () {
                                    selectedCountry = value;
                                  },
                                );
                              },
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}',
                                style: const TextStyle(
                                    fontSize: 16,
                                    color: LivitColors.whiteActive),
                              ),
                            ],
                          ),
                        ),
                      ),
                      suffixIcon: valid
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: Icon(
                                Icons.done,
                                color: Color.fromARGB(255, 255, 255, 255),
                                size: 18,
                              ),
                            )
                          : null),
                ),
                const SizedBox(
                  height: 20,
                ),
                MainActionButton(
                    text: 'Next',
                    isActive: valid,
                    onPressed: () {
                      verifyPhone(
                        scaffoldKey,
                        selectedCountry.phoneCode,
                        _numberFieldController.text,
                      );
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }

  void verifyPhone(GlobalKey key, String phoneCode, String phoneNumber) {
    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+$phoneCode $phoneNumber',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (error) {
        if (error.code == 'invalid-phone-number') {
          showErrorDialog(key, 'Invalid Phone Number',
              'Please check if you entered a valid phone number');
        } else {
          showErrorDialog(
            key,
            'Something went wrong',
            error.code.toString(),
          );
        }
      },
      codeSent: (verificationId, forceResendingToken) {
        Navigator.of(context)
            .pushNamed(Routes.otpAuthRoute, arguments: verificationId);
      },
      codeAutoRetrievalTimeout: (verificationId) {},
    );
  }
}
