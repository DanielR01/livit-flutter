import 'package:country_picker_pro/country_picker_pro.dart';
import 'package:flutter/material.dart';

class LoginNumberView extends StatefulWidget {
  const LoginNumberView({super.key});

  @override
  State<LoginNumberView> createState() => LoginNumberViewState();
}

class LoginNumberViewState extends State<LoginNumberView> {
  late final TextEditingController _number;

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
    _number = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  onChanged: (value) {
                    setState(() {
                      _number.text = value;
                    });
                  },
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                  controller: _number,
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
                    suffixIcon: _number.text.length > 9
                        ? Container(
                            height: 16,
                            width: 16,
                            child: const Icon(
                              Icons.done,
                              color: Color.fromARGB(180, 255, 255, 255),
                              size: 18,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text("Next"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
