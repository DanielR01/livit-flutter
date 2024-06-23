import 'package:livit/constants/routes.dart';
import 'package:country_picker_pro/country_picker_pro.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:livit/utilities/show_error_dialog_2t_1b.dart';
import 'dart:developer' as devtools show log;

class LoginNumberView extends StatefulWidget {
  const LoginNumberView({super.key});

  @override
  State<LoginNumberView> createState() => LoginNumberViewState();
}

class LoginNumberViewState extends State<LoginNumberView> {
  final GlobalKey scaffold_key = GlobalKey<ScaffoldState>();
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
      key: scaffold_key,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
            child: Column(
              children: [
                const Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Enter your phone number. We will send you a verification code:',
                  style: TextStyle(
                    fontSize: 14,
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
                      if (_numberFieldController.text.length < 9 ||
                          _numberFieldController.text.length > 15 ||
                          !RegExp(r'^(\+|00)?[0-9]+$')
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
                  ),
                  controller: _numberFieldController,
                  decoration: InputDecoration(
                      hintText: 'Enter phone number',
                      hintStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white12),
                      ),
                      prefixIcon: Container(
                        padding: const EdgeInsets.all(16),
                        child: InkWell(
                          onTap: () {
                            showCountryListView(
                              searchBarOuterBackgroundColor:
                                  const Color.fromARGB(255, 22, 21, 24),
                              searchBarBackgroundColor:
                                  const Color.fromARGB(255, 22, 21, 24),
                              appBarBackgroundColour:
                                  const Color.fromARGB(255, 22, 21, 24),
                              backgroundColour:
                                  const Color.fromARGB(255, 22, 21, 24),
                              countryTextColour:
                                  const Color.fromARGB(200, 255, 255, 255),
                              searchBarBorderColor:
                                  const Color.fromARGB(31, 255, 255, 255),
                              searchBarHintColor:
                                  const Color.fromARGB(200, 255, 255, 255),
                              searchBarTextColor:
                                  const Color.fromARGB(200, 255, 255, 255),
                              context: context,
                              onSelect: (value) {
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
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      suffixIcon: valid
                          ? InkWell(
                              borderRadius: BorderRadius.circular(9),
                              onTap: () {
                                verifyPhone(
                                    scaffold_key,
                                    selectedCountry.phoneCode,
                                    _numberFieldController.text);
                              },
                              child: const SizedBox(
                                height: 16,
                                width: 16,
                                child: Icon(
                                  Icons.done,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  size: 18,
                                ),
                              ),
                            )
                          : null),
                ),
                const SizedBox(
                  height: 10,
                ),
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
        Navigator.of(context).pushNamed(otpAuthRoute);
      },
      codeAutoRetrievalTimeout: (verificationId) {},
    );
  }
}
